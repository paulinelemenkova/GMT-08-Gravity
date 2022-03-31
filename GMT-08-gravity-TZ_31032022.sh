#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Tanzania)
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
gmt img2grd grav_27.1.img -R29/42/-13/0 -Ggrav.grd -T1 -I1 -E -S0.1 -V
gmt grdcut grav.grd -R29/42/-13/0 -Gtz_grav.nc
gdalinfo -stats tz_grav.nc
# Minimum=-240.011, Maximum=539.511
gmt makecpt -Chaxby -T-200/200/1 > colors.cpt
# gmt makecpt --help

ps=Grav_TZ.ps
# Make raster image
gmt grdimage tz_grav.nc -Ccolors.cpt -R29/42/-13/0 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg27.5/-13.0+w16.5c/0.15i+v+o0.3/0i+ml+e -R -J -Ccolors.cpt \
	--FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --FONT_TITLE=9p,0,black \
	-Bg25f5a50+l"Colour scale 'jet' (Dark to light blue, white, yellow and red [C=RGB] -183/278/1)" \
	-I0.2 -By+lmGal -O -K >> $ps
    
# Add isolines
gmt grdcontour tz_grav.nc -R -J -C25 -A50 -Wthinnest -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=wESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg1f0.5a1 -Bpyg1f0.5a1 -Bsxg2 -Bsyg1 \
    -B+t"Free-air gravity anomaly for Tanzania" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,0,black \
    --FONT_ANNOT_PRIMARY=8p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.5c+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps

gmt psbasemap -R -J \
    --FONT_TITLE=9p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    -Tdx1.0c/0.4c+w0.5i+f2+l+o0.2i \
    -O -K >> $ps

# Texts
# Cities
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
39.5 -6.1 Zanzibar City
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.3 -6.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
32.7 -4.9 Tabora
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.5 -5.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
32.55 -3.4 Kahama
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.4 -3.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
39.1 -4.9 Tanga
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.0 -5.0 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
37.5 -6.4 Morogoro
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
37.4 -6.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
33.4 -8.4 Mbeya
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.3 -8.5 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f12p,13,black+jLB -Gwhite@30 >> $ps << EOF
35.6 -6.4 Dodoma
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
35.4 -6.1 0.35c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
36.5 -3.1 Arusha
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
36.4 -3.2 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
32.5 -2.63 Mwanza
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.5 -2.3 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f11p,13,black+jLB -Gwhite@30 >> $ps << EOF
39.2 -6.6 Dar es Salaam
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
39.1 -6.5  0.20c
EOF

# Lakes
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,blue+jLB+a-80 >> $ps << EOF
29.4 -5.1 Lake
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,blue+jLB+a-65  >> $ps << EOF
30.0 -6.8 Tanganyika
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,13,blue+jLB -Gwhite@30 >> $ps << EOF
32.3 -0.9 Lake
32.2 -1.3 Victoria
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,13,blue+jLB+a-85 >> $ps << EOF
34.3 -10.2 Lake Nyasa
EOF

# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB+a-80 -Gwhite@30 >> $ps << EOF
33.8 -11.1 MALAWI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@30 >> $ps << EOF
30.3 -10.8 Z A M B I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@30 >> $ps << EOF
29.1 -7.5 CONGO
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@30 >> $ps << EOF
29.3 -3.5 BURUNDI
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@30 >> $ps << EOF
29.4 -1.95 RWANDA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@30 >> $ps << EOF
30.1 -0.5 U G A N D A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@30 >> $ps << EOF
37.0 -0.9 K E N Y A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f22p,13,black+jLB >> $ps << EOF
31.75 -5.7 T  A  N  Z  A  N  I  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,25,black+jLB -Gwhite@30 >> $ps << EOF
36.1 -12.4 M O Z A M B I Q U E
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,13,blue+jLB >> $ps << EOF
40.5 -8.5 Indian
40.5 -9.5 Ocean
EOF

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y11.3c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.3 Global satellite derived gravity grid (CryoSat-2 and Jason-1).
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_TZ.ps -A0.5c -E720 -Tj -Z
