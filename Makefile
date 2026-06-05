build:
	rm -f dist/data.zip
	mkdir -p dist
	cd data && zip -r ../dist/data.zip .
