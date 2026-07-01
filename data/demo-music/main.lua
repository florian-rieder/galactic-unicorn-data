local Music = require("lib.music")

function setup()
  Music.set_tempo(140)
  Music.set_ticks_per_beat(4)
  Music.play("E4:2 B3:1 C4:1 D4:2 C4:1 B3:1 A3:2 A3:1 C4:1 E4:2 D4:1 C4:1 B3:3 C4:1 D4:2 E4:2 C4:2 A3:2 A3:3 D4:2 F4:1 A4:2 G4:1 F4:1 E4:3 C4:1 E4:2 D4:1 C4:1 B3:2 B3:1 C4:1 D4:2 E4:2 C4:2 A3:2 A3:3", true)
end

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
