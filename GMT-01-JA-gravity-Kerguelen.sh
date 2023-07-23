#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO global data set (here: Kergelen)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Step-3. Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

exec bash

# Convert file from IMG format to GRD format
gmt img2grd grav_27.1.img -R-40/150/-70/-10 -Ggrav_Ker.grd -T1 -I1 -E -S0.1 -V

gdalinfo grav_Ker.grd -stats
# -166.277099609375,546.4031982421875
# Make color palette
gmt makecpt -Chaxby -V -T-100/150 > myocean.cpt
#makecpt --help

# Generate a file
ps=Gravity_Kgl_JA.ps

gmt grdimage grav_Ker.grd -Cmyocean.cpt -R-25/-65/101/-10r -JA55/-50/7.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add isolines
gmt grdcontour grav_Ker.grd -R -J -C50 -A50 -Wthinner -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    -Bpxg10f5a20 -Bpyg10f5a15 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=1.8c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=10p,0,dimgray \
    --FONT_LABEL=11p,0,dimgray \
    --FONT_TITLE=12p,0,black \
    -B+t"Free-air gravity anomaly on Kerguelen Plateau" \
    -Lx16.5c/-1.7c+c318/-57+w2000k+l"Scale (km) at 55\232E 50\232S"+f \
    -UBL/-5p/-50p -O -K >> $ps

# Texts

# Add legend
gmt psscale -Dg-30/-58+w15.4c/0.4c+v+ml+e -R -J -Cmyocean.cpt \
    --FONT_LABEL=10p,0,black \
    --FONT_ANNOT_PRIMARY=11p,Helvetica,black \
    -Bg20f2a20+l"Color scale: haxby [R=-100/547, H=0, C=RGB]" \
    -I0.2 -By+l"mGal" -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f11p,0,black+jLB >> $ps << EOF
1.0 6.6 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA
1.0 5.7 Lambert Azimuthal Equal-Area projection. Central meridian 55\232E, standard parallel 50\232S
EOF

# Convert to image file using GhostScript
gmt psconvert Gravity_Kgl_JA.ps -A1.7c -E720 -Tj -Z
