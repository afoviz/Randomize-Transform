# Randomize Transform

A 3ds Max MaxScript utility for randomizing the position, rotation and scale of one or more selected objects.

3ds Max script · 3ds Max 2020 or newer · MaxScript, .NET WinForms

Useful for quickly scattering assets, breaking up repetition, and adding natural variation to scenes.

## Features

- **Per-axis ranges**: independent X, Y and Z ranges (+/-) for position and rotation.
- **Scale**: uniform or non-uniform scale variation.
- **Random seed**: repeatable results from a custom seed.
- **Live preview**: changes are previewed interactively in real time, then either kept (**Apply / Keep result**) or reverted to the objects' original transforms (**Revert**).
- **Presets**: built-in Default settings, Subtle Position, Rotation Variation, Scale Variation and Full Variation, plus up to 20 custom presets you can save, overwrite, rename and delete. The default settings cannot be overwritten, renamed or deleted.

## Install

1. In 3ds Max, open **Scripting → Run Script…**.
2. Choose `Randomize_Transform_2.00.ms`.

Built for 3ds Max 2020+. Older version compatibility is not guaranteed.

## Usage

1. Select one or more objects.
2. Set the Position, Rotation and Scale ranges and, if you want a repeatable result, a random seed.
3. Watch the preview in the viewport, then click **Apply / Keep result** or **Revert**.

## License and credits

GPL-3.0 (see `LICENSE`). Script by Afonso Gonçalves, [afoviz.com](https://www.afoviz.com).
