local NOTE_MAP = {
  ["C"]  = 0,
  ["C#"] = 1,
  ["D"]  = 2,
  ["D#"] = 3,
  ["E"]  = 4,
  ["F"]  = 5,
  ["F#"] = 6,
  ["G"]  = 7,
  ["G#"] = 8,
  ["A"]  = 9,
  ["A#"] = 10,
  ["B"]  = 11,
}

local sequence = nil;
local bpm = 120;
local ticks_per_beat = 4;
local index = 1;
local loop = false;
local is_playing = false;
local time_since_last_note = 0;
local last_note_duration = 0;

local Music = {}


local function tick_to_ms(ticks)
  return (ticks / ticks_per_beat) * (60 / bpm) * 1000;
end

-- Convert the note (e.g. "A4") to a frequency (e.g. 440 Hz)
local function note_to_frequency(note)
  -- "0" denotes a rest
  if note == "0" then return 0 end

  local note_name, octave_text = note:match("^([A-Ga-g]#?)(%d)$")
  local name = note_name:upper()
  local octave = tonumber(octave_text);

  local semitone = NOTE_MAP[name];

  if not semitone then
    error("Invalid note: " .. note, 2);
  end

  local n = (octave + 1) * 12 + semitone;
  return 440 * 2 ^ ((n - 69) / 12);
end

-- Parse a sequence string into a sequence of notes and durations
local function parse_music(music_string)
  local seq = {}
  -- Parse the sequence string and create a list of notes and durations
  for token in music_string:gmatch("%S+") do
    local note_text, duration_ticks = token:match("([^:]+):([^:]+)")

    -- Convert the note text to a frequency
    local frequency_hz = note_to_frequency(note_text);

    -- Convert the duration ticks to milliseconds
    local duration_ms = tick_to_ms(tonumber(duration_ticks));

    table.insert(seq, { frequency_hz, duration_ms })
  end

  return seq
end

local function play_next_note()
  if not sequence or #sequence == 0 then return end

  if index > #sequence then
    -- If we've reached the end of the sequence, loop if enabled
    if loop then
      index = 1
    else
      -- If we've reached the end of the sequence and looping is disabled, stop the sequence
      Music.stop();
      return
    end
  end

  local note = sequence[index]
  local frequency_hz = math.floor(note[1])
  local duration_ms = math.floor(note[2])

  -- If the note is not a rest (frequency 0), play the note for the given duration
  if frequency_hz ~= 0 then
    buzz(frequency_hz, duration_ms);
  end

  time_since_last_note = 0
  last_note_duration = duration_ms

  -- Move the needle to the next n++;
  index = index + 1
end


function Music.set_tempo(new_bpm)
  if (new_bpm <= 0) then
    error("Tempo must be greater than 0.", 2)
  end
  bpm = new_bpm
end

function Music.set_ticks_per_beat(new_ticks_per_beat)
  if (new_ticks_per_beat <= 0) then
    error("Ticks per beat must be greater than 0.", 2);
  end
  ticks_per_beat = new_ticks_per_beat;
end

function Music.play(music_string, do_loop)
  if do_loop == nil then do_loop = false end

  loop = do_loop

  -- Parse the sequence string and create a list of notes and durations
  sequence = parse_music(music_string);

  if sequence == nil or #sequence == 0 then
    error("No sequence to play.", 2);
  end

  is_playing = true;
end

function Music.pause()
  is_playing = false;
end

function Music.resume()
  -- If the sequence is already playing, don't resume it
  if is_playing then return end
  is_playing = true
end

function Music.stop() 
  if not sequence then return end

  sequence = nil;
  is_playing = false;
  time_since_last_note = 0;
  last_note_duration = 0;
end

function Music.is_playing()
  return is_playing
end

function Music.process(dt)
  if not is_playing then return end

  time_since_last_note = time_since_last_note + dt

  local elapsed_ms = time_since_last_note * 1000
  if elapsed_ms >= last_note_duration then
    play_next_note()
  end
end

if (...) == nil then
  Music.set_tempo(140)
  Music.set_ticks_per_beat(4)
  Music.play("E4:2 B3:1 C4:1 D4:2 C4:1 B3:1 A3:2 A3:1 C4:1 E4:2 D4:1 C4:1 B3:3 C4:1 D4:2 E4:2 C4:2 A3:2 A3:3 D4:2 F4:1 A4:2 G4:1 F4:1 E4:3 C4:1 E4:2 D4:1 C4:1 B3:2 B3:1 C4:1 D4:2 E4:2 C4:2 A3:2 A3:3", true)

  function process(delta_time)
    Music.process(delta_time)
  end

  function on_press(button_name)
    if button_name == "MENU" then 
      if Music.is_playing() then
        Music.pause()
      else
        Music.resume()
      end
    end
  end

end

return Music
