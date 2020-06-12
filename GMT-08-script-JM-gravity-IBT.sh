#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Izu-Bonin Trench).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_IBT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,gray30 \
    MAP_GRID_CROSS_SIZE_PRIMARY=1.0c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R128/150/20/36 -Ggrav.grd -T1 -I1 -E -S0.1 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt grav.grd -Crainbow > grav.cpt
# Step-5. Generate gravity image with shading
gmt grdimage grav.grd -I+a45+nt1 -R128/150/20/36 -JM16c -Cgrav.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p \
-Df -B+t"Marine free-air gravity anomaly: Izu-Bonin Trench area" \
	-Bxa4g3f2 -Bya4g3f2 \
    -O -K >> $ps
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=0.15c \
    -Tdg143/58.5+w0.5c+f2+l \
    -Lx13.5c/-1.3c+c50+w500k+l"Mercator projection. Scale, km"+f \
    -UBL/-5p/-40p -O -K >> $ps
# Step-8. Add legend
gmt psscale -R -J -Cgrav.cpt \
    -Dg124.5/20+w13.0c/0.5c+v+o0.7/0i+ml  \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Baf+l"Marine free-air gravity anomaly color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,navy+jLB >> $ps << EOF
144.5 30.0 PACIFIC OCEAN
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB >> $ps << EOF
130 32.5 KYUSHU
134.0 35.0 HONSHU
135.8 29.5 SHIKOKU BASIN
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,gold+jLB+a-254 >> $ps << EOF
144.0 27.5 I  z  u - B  o  n  i  n
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,gold+jLB+a-265 >> $ps << EOF
142.6 31.9 T  r  e  n  c  h
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times−Bold,darkblue+jLB  >> $ps << EOF
142.9 35.0 Boso
142.9 34.5 Triple Junction
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times−Bold,white+jLB+a-310 >> $ps << EOF
129.2 25.6 Nankai
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times−Bold,white+jLB+a-310 >> $ps << EOF
131.4 28.5 Trough
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times−Bold,white+jLB+a-335 >> $ps << EOF
135 32.2 Suruga
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times−Bold,white+jLB+a-325 >> $ps << EOF
137.2 33.0 Trough
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times−Bold,darkblue+jLB+a-20 >> $ps << EOF
139.7 34.3 Sagami
139.7 33.8 Trough
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times−Bold,gold+jLB+a-80 >> $ps << EOF
141.8 28.7 Bonin Ridge
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,white+jLB+a-44 >> $ps << EOF
144.4 23.5 Mariana
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,Helvetica−Bold,white+jLB+a-62 >> $ps << EOF
146.7 21.6 Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB+a-80 -Gwhite@30 >> $ps << EOF
140.3 33.0 I  Z  U - B  O  N  I  N   V  O  L  C  A  N  I  C   A  R  C
EOF
# Step-0. Add logo
gmt logo -R -J -Dx6.5/-2.0+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y4.2c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
2.5 15.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_IBT.ps -A0.2c -E720 -Tj -P -Z
