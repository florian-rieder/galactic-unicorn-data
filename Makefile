build:
	rm -f dist/data.zip
	mkdir -p dist
	zip -r dist/data.zip * -x dist/* -x Makefile -x .gitignore -x .editorconfig -x .github -x .git/*