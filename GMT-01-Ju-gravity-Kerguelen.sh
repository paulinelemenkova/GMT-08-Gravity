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
gmt img2grd grav_27.1.img -R40/110/-70/-20 -Ggrav_Ker.grd -T1 -I1 -E -S0.1 -V

gdalinfo grav_Ker.grd -stats
# -166.277099609375,546.4031982421875
# Make color palette
gmt makecpt -Chaxby -V -T-100/150 > myocean.cpt
#makecpt --help

# Generate a file
ps=Gravity_Kgl.ps

gmt grdimage grav_Ker.grd -Cmyocean.cpt -R40/110/-70/-20 -JU43/6.0i -P -I+a15+ne0.75 -Xc -K > $ps

# Add isolines
gmt grdcontour grav_Ker.grd -R -J -C50 -A50 -Wthinner -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    -Bpxg10f5a10 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=2.3c \
    --MAP_ANNOT_OFFSET=0.1c \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,dimgray \
    --FONT_LABEL=10p,Helvetica,dimgray \
    --FONT_TITLE=12p,Helvetica,black \
    -B+t"Free-air gravity anomaly on Kerguelen Plateau" \
    -Lx7.5c/-1.3c+c318/-57+w2000k+l"UTM projection, Zone 43. Scale (km)"+f \
    -UBL/10p/-40p -O -K >> $ps

# Texts

# Add legend
gmt psscale -Dg41/-12.5+w15.4c/0.4c+ml+h+e -R -J -Cmyocean.cpt \
    --FONT_LABEL=8p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=8p,Helvetica,black \
    -Bg20f2a20+l"Color scale: haxby [R=-100/547, H=0, C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
# gmt logo -Dx7.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y13.0c -N -O \
    -F+f10p,0,black+jLB >> $ps << EOF
1.0 1.3 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA
EOF

# Convert to image file using GhostScript
gmt psconvert Gravity_Kgl.ps -A1.0c -E720 -Tj -Z
