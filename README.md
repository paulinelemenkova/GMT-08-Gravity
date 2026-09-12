# GMT Gravity — Marine Free-Air and Bouguer Gravity Anomaly Mapping Scripts

A collection of over 70 GMT (Generic Mapping Tools) shell scripts for mapping the Earth's gravity field, focusing on marine free-air and Bouguer gravity anomalies derived from satellite-altimetry gravity grids. Anomaly grids are colour-shaded and contoured over countries, seas and ocean trenches. The scripts have been used to generate map figures across the author's geophysical, geodetic and cartographic publications.

## What the scripts do

Each script builds a complete gravity-anomaly map, typically chaining:

- extraction of a regional subset from the global gravity .img grid (img2grd)
- colour palette generation from the grid (grd2cpt / makecpt)
- gravity grid rendering with illumination (grdimage)
- coastlines, frames and titles (pscoast)
- anomaly contours where used (grdcontour)
- colour scale bars in mGal (psscale), grids and scale bars (psbasemap)
- directional and magnetic roses (psbasemap -T)
- annotations, subtitles and labels (pstext), GMT logo (logo)
- export to raster (psconvert) at high resolution

Variants tagged _curv compute curvature / vertical-gradient (edge-enhanced) versions of the anomaly field. Map projections are chosen per region (Mercator, equidistant conic, etc.).

## Data sources

Global marine gravity model from satellite radar altimetry (Sandwell & Smith; CryoSat-2 and Jason-1), supplied as .img grids and converted with img2grd. Coastlines from GSHHG via GMT.

## File naming

Scripts follow GMT-08-...-gravity-XX.sh, where XX is an ISO country code or a feature tag: countries (e.g. TZ = Tanzania, VE = Venezuela, IR = Iran), ocean trenches (e.g. KKT = Kuril-Kamchatka Trench, MAT = Middle America Trench, PSB = Philippine Sea Basin) and seas. A -curv suffix denotes the curvature / vertical-gradient variant; _Bouguer denotes a Bouguer anomaly map.

## Requirements

- GMT 6.x (Generic Mapping Tools): https://www.generic-mapping-tools.org
- A POSIX shell (bash/sh)
- The global marine gravity .img grid available locally

## Usage

Place the required gravity .img grid in the working directory, adjust the -R region and -J projection at the top of the chosen script, then run:

    bash GMT-08-script-JM-gravity-KKT.sh

The script writes a PostScript file and converts it to a raster image (JPG/PNG) via psconvert.

## Author and citation

Polina Lemenkova
ORCID: https://orcid.org/0000-0002-5759-1089

These scripts accompany figures in the author's geophysical, geodetic and cartographic papers; please cite the specific article a given map appears in. The full publication list is available via the ORCID record above.

## License

See the LICENSE file in this repository.
