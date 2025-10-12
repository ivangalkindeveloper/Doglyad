.PHONY: lint gen l10n
.SILENT:

lint:
	swiftgen lint
	
gen:
	swiftgen

l10n:
	l10n-xcstrings --input Doglyad/Resources/Localizable.xcstrings --output-swift Doglyad/Resources/Generated/Strings+Generated.swift
