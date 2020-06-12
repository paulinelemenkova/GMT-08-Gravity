#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Peru-Chile Trench).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_PCT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1.0c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinner,white \
    MAP_GRID_CROSS_SIZE_PRIMARY=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R270/300/-55/0 -GgravPCT.grd -T1 -I1 -E -S0.1 -V
img2grd curv_27.1.img -R270/300/-55/0 -GcurvPCT.grd -T1 -I1 -E -S0.01 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt gravPCT.grd -Crainbow > gravPCT.cpt
# Step-5. Generate gravity image with shading
gmt grdimage gravpCT.grd -I+a45+nt1 -R270/300/-55/0 -JM4.5i -CgravPCT.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p \
    -Df -B+t"Marine free-air gravity anomaly for the Peru-Chile Trench area" \
	-Bxg3f2a4 -Byg3f2a4 \
    -O -K >> $ps
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,black \
    --MAP_ANNOT_OFFSET=.2c \
    --MAP_TITLE_OFFSET=.3c \
    -Tdg277/-50+w0.5c+f2+l \
    -Lx3.5i/-1.0i+c50+w600k+l"Mercator projection. Scale, km"+f \
    -UBL/-10p/-75p -O -K >> $ps
# Step-8. Add color legen3
gmt psscale -R -J -CgravPCT.cpt \
    -DjBC+o0.0c/-2.0c+w12c/0.5c+h\
    --FONT_LABEL=7p,Palatino-Roman,dimgray \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    --MAP_LABEL_OFFSET=0.1c \
    -Baf+l"Marine free-air gravity anomaly color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# Step-0. Add logo
gmt logo -R -J -Dx4.5/-3.5+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X-0.0c -Y15.8c -N -O \
    -F+f12p,Palatino-Roman,black+jLB >> $ps << EOF
0.0 15.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_PCT.ps -A1.0c -E720 -Tj -P -Z
