#!/bin/sh
# Purpose: Gravity model map
# Mercator projection (here: Yap and Palau trenches).
# GMT modules: gmtset, img2grd, grd2cpt, grdimage, pscoast, psbasemap, psscale, logo, pstext, psconvert
# Step-1. Generate a file
ps=Grav_YPT.ps
# Step-2. GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_TITLE_OFFSET=1c \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thinnest,gray30 \
    MAP_GRID_CROSS_SIZE_PRIMARY=0.5c \
    MAP_ANNOT_OFFSET=0.1c \
    FONT_TITLE=14p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray \
    MAP_LABEL_OFFSET=0.1c
# Step-3. Extract subset of img file in Mercator or Geographic format
img2grd grav_27.1.img -R116/145/-6/20 -Ggrav.grd -T1 -I1 -E -S0.1 -V
# Step-4. Generate a color palette table from grid
gmt grd2cpt grav.grd -Crainbow > grav.cpt
# Step-5. Generate gravity image with shading
gmt grdimage grav.grd -I+a45+nt1 -R116/145/-6/20 -JM16c -Cgrav.cpt -P -K > $ps
# Step-6. Add basemap: grid, title, costline
gmt pscoast -R -J -P \
	-V -W0.25p \
-Df -B+t"Marine free-air gravity anomaly: Yap and Palau trenches area" \
	-Bxa4g3f2 -Bya4g3f2 \
    -O -K >> $ps
# Step-7. Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=8p,Palatino-Roman,dimgray \
    --MAP_ANNOT_OFFSET=0.15c \
    -Tdg143/58.5+w0.5c+f2+l \
    -Lx13.5c/-1.3c+c50+w500k+l"Mercator projection. Scale, km"+f \
    -UBL/-5p/-40p -O -K >> $ps
# Step-8. Add legend
gmt psscale -R -J -Cgrav.cpt \
    -Dg110.5/-6+w14.0c/0.5c+v+o0.7/0i+ml  \
    --FONT_LABEL=7p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    --MAP_ANNOT_OFFSET=0.1c \
    --MAP_LABEL_OFFSET=0.1c \
    -Baf+l"Marine free-air gravity anomaly color scale" \
    -I0.2 -By+lmGal -O -K >> $ps
# texts
gmt pstext -R -J -N -O -K \
-F+f8p,Palatino-Roman,black+jLB -Gwhite@30 >> $ps << EOF
116.5 1.5 KALIMANTAN
119 -2.0 SULAWESI
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,black+jLB -Gwhite@20 >> $ps << EOF
121 12.0 PHILIPPINES
137 -4.0 PAPUA NEW GUINEA
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,darkblue+jLB -Gwhite@30 >> $ps << EOF
128.5 13.5 PHILIPPINE SEA
136 18.5 P A C I F I C  O C E A N
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,Times-Roman,darkblue+jLB -Gwhite@30 >> $ps << EOF
120.5 3.5 CELEBES SEA
118.5 8 SULU SEA
117 17 SOUTH
117 16.4 CHINA
117 15.8 SEA
127 -5 BANDA SEA
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jLB+a-308 -Gwhite@30 >> $ps << EOF
137.8 6.6 Yap Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jLB+a-310 -Gwhite@30 >> $ps << EOF
133.6 4.2 Palau Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jBL+a-72 -Gwhite@30 >> $ps << EOF
126.5 13.0 Philippine Trench
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,Palatino-Roman,red+jBL+a-350 -Gwhite@30 >> $ps << EOF
141 9.8 Mariana Trench
EOF
# Step-0. Add logo
gmt logo -R -J -Dx6.5/-2.2+o0.1i/0.1i+w2c -O -K >> $ps
# Step-10. Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.3c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
3.0 15.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution
EOF
# Step-11. Convert to image file using GhostScript (portrait orientation, 720 dpi)
gmt psconvert Grav_YPT.ps -A0.2c -E720 -Tj -P -Z
