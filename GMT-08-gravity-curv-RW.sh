#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Rwanda)
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert

# GMT set up
gmt set FORMAT_GEO_MAP=dddF \
    MAP_FRAME_PEN=dimgray \
    MAP_FRAME_WIDTH=0.1c \
    MAP_TITLE_OFFSET=1c \
    MAP_ANNOT_OFFSET=0.1c \
    MAP_TICK_PEN_PRIMARY=thinner,dimgray \
    MAP_GRID_PEN_PRIMARY=thin,white \
    MAP_GRID_PEN_SECONDARY=thinnest,white \
    FONT_TITLE=12p,Palatino-Roman,black \
    FONT_ANNOT_PRIMARY=7p,0,dimgray \
    FONT_LABEL=7p,0,dimgray \
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

# Extract subset of img file in Mercator or Geographic format
gmt img2grd curv_27.1.img -R28.5/31/-3/-1 -Ggrav_v.grd -T1 -I1 -E -S0.1 -V
gmt grdcut grav_v.grd -R28.5/31/-3/-1 -Grw_grav_v.nc
gdalinfo -stats rw_grav_v.nc
# Minimum=-199.742, Maximum=418.269, Mean=5.492, StdDev=51.828
gmt makecpt -Cseis -T-200/200/1 -Ic > colors.cpt
# gmt makecpt --help cubhelix cyclic
# -Ic

ps=Grav_RW_v.ps
# Make raster image
gmt grdimage rw_grav_v.nc -Ccolors.cpt -R28.5/31/-3/-1 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg28.5/-3.2+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Ccolors.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg25f5a50+l"Color scale 'jet' (Dark to light blue, white, yellow and red [C=RGB] -183/278/1)" \
	-I0.2 -By+lmGal -O -K >> $ps
    
# Add isolines
gmt grdcontour rw_grav_v.nc -R -J -C25 -A50 -Wthinnest -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a0.25 -Bpyg1f0.5a0.25 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -B+t"Vertical free-air gravity anomaly for Rwanda" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.5c+c50+w50k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

gmt psbasemap -R -J \
    --FONT_TITLE=7p,0,white \
    --MAP_TITLE_OFFSET=0.1c \
    -Tdx1.0c/0.4c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps

# Texts
# Lakes
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
29.2 -1.95 Lake
29.2 -2.05 Kivu
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.32 -2.32 Lake
30.32 -2.37 Rweru
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.75 -1.81 Lake
30.75 -1.86 Ihema
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.31 -2.05 Lake
30.31 -2.10 Mugesera
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.4 -1.85 Lake Muhazi
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
29.78 -1.45 Lake Burera
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
29.74 -1.51 Lake Ruhondo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,blue2+jLB >> $ps << EOF
30.0 -2.25 Lake
29.9 -2.3 Cyohoha South
EOF

# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.4 -1.1 U  G  A  N  D  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.4 -2.9 B U R U N D I
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.55 -2.65 T A N Z A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,0,black+jLB -Gwhite@60 >> $ps << EOF
28.6 -1.6 C O N G O
28.6 -1.7 (D.R.C.)
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,26,blue2+jLB >> $ps << EOF
29.6 -2.15 R    W    A    N    D    A
EOF
# Cities
gmt pstext -R -J -N -O -K \
-F+f13p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.08 -1.90 Kigali
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
30.06 -1.94 0.40c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.00 -1.5 Byumba
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.06 -1.57 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.30 Nyanza
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.73 -2.35 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.44 -1.97 Rwamagana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.43 -1.95 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.04 Muhanga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.75 -2.08 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.36 -2.03 Kibuye
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.35 -2.06 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
29.70 -2.55 Butare
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
29.75 -2.6 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
28.90 -2.46 Cyangugu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
28.89 -2.48 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.56 -2.10 Kibungo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.54 -2.15 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f10p,0,black+jLB -Gwhite@60 >> $ps << EOF
30.33 -1.31 Nyagatare
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.32 -1.29 0.20c
EOF

# Add GMT logo
gmt logo -Dx7.0/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.0c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
2.7 9.2 Global satellite derived gravity grid (CryoSat-2 and Jason-1).
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_RW_v.ps -A0.5c -E720 -Tj -Z
