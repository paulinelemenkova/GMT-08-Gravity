#!/bin/sh
# Purpose: Vertical gravity model map
# Mercator projection (here: Mariana Trench).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Curv_MT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest \
    MAP_GRID_CROSS_SIZE_PRIMARY=0.1i \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd curv_27.1.img -R120/160/0/30 -Gcurv.grd -T1 -I1 -E -S0.1 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt curv.grd -CGMT_haxby > curv.cpt
# Step-5. Generate gravity image with shading
gmt grdimage curv.grd -I+a45+nt1 -R120/160/0/30 -JM6i -Ccurv.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p \
    -Df -B+t"Marine free-air vertical gravity anomaly: Mariana Trench area" \
	-Bxa4g3f2 -Bya4g3f2 \
    -O -K >> $ps
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=0.0c \
    -Tdg156/4+w0.5c+f2+l \
    -Lx5.2i/-0.5i+c50+w800k+l"Mercator projection. Scale, km"+f \
    -UBL/-15p/-40p -O -K >> $ps
# Step-8. Add color legend
gmt psscale -R -J -Ccurv.cpt \
    -Dg114/0+w10c/0.3c+v+o0.5/0c+ml  \
    --FONT_LABEL=8p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=5p,Helvetica,dimgray \
    -Baf+l"Marine free-air vertical gravity modelling color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# Step-9. Add logo
gmt logo -R -J -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X-2.2c -Y3.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 15.0 Global free-air vertical gravity gradient grid: CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Curv_MT.ps -A0.2c -E720 -Tj -P -Z
