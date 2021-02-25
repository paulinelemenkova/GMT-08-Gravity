#!/bin/sh
# Purpose: geoid of Uganda
# GMT modules: gmtset, gmtdefaults, grdcut, makecpt, grdimage, psscale, grdcontour, psbasemap, gmtlogo, psconvert
# http://soliton.vm.bytemark.co.uk/pub/cpt-city/njgs/index.html

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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

gmt img2grd curv_27.1.img -R29/35.5/-1.5/4.3 -Ggrav_v_UG.grd -T1 -I1 -E -S0.1 -V
gdalinfo grav_v_UG.grd -stats
# Minimum=-635.016, Maximum=630.213, Mean=0.285, StdDev=37.040

# Generate a color palette table from grid
# gmt makecpt --help
gmt makecpt -Cradar_dbz -T-100/100 > colors.cpt
#-Ic Reverse sense of color table spectrum

# Generate a file
ps=Grav_UG.ps

gmt grdimage grav_v_UG.grd -Ccolors.cpt -R29/35.5/-1.5/4.3 -JM6.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add isolines
gmt grdcontour grav_v_UG.grd -R -J -C100 -A100 -Wthinner -O -K >> $ps

# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    -Bpxg1f0.5a1 -Bpyg1f0.5a0.5 -Bsxg1 -Bsyg1 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,25,black \
    -B+t"Vertical gravity gradient grid for Uganda" -O -K >> $ps
    
# Add legend
gmt psscale -Dg29.0/-2.0+w16.5c/0.15i+h+o0.3/0i+ml+e -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=8p,25,black \
    -Bg20f2a20+l"CPT 'radar dbz' by Integrated Data Viewer (IDV) from Unidata framework for analyzing and visualizing geoscience data. [C=RGB -T-100/100]" \
    -I0.2 -By+lm -O -K >> $ps

# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-2.4c+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/-10p/-70p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thickest,white -Wthinner -Df -O -K >> $ps

# Texts
# Cities
gmt pstext -R -J -N -O -K \
-F+f11p,0,black+jLB -Gwhite@40 >> $ps << EOF
32.65 0.18 Kampala
EOF
gmt psxy -R -J -Ss -W0.5p -Gred -O -K << EOF >> $ps
32.58 0.31 0.30c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
32.10 0.40 Nansana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.52 0.36 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-345 -Gwhite@40 >> $ps << EOF
32.62 0.45 Kira
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.63 0.40 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
31.9 0.14 Ssabagabo
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.56 0.24 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
30.70 -0.65 Mbarara
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.65 -0.61 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB+a-345 -Gwhite@40 >> $ps << EOF
32.80 0.40 Mukono
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.75 0.36 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
33.20 0.43 Njeru
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
33.15 0.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
32.05 2.82 Gulu
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.30 2.78 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
33.00 0.33 Lugazi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.94 0.37 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
31.80 -0.30 Masaka
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.74 -0.34 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
30.15 0.15 Kasese
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
30.08 0.19 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
31.40 1.48 Hoima
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.35 1.43 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
32.95 2.27 Lira
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.9 2.25 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
31.60 0.40 Mityana
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
32.04 0.40 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
31.45 0.60 Mubende
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.40 0.55 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
31.75 1.75 Masindi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
31.72 1.68 0.20c
EOF
gmt pstext -R -J -N -O -K \
-F+f9p,0,black+jLB -Gwhite@40 >> $ps << EOF
34.0 1.15 Mbale
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
34.17 1.07 0.20c
EOF
#
# Hydrology
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,26,blue2+jLB -Gwhite@60 >> $ps << EOF
32.8 -0.40 L a k e
32.8 -0.70 V i c t o r i a
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-315 -Gwhite@60 >> $ps << EOF
30.53 1.15 L a k e  A l b e r t
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB+a-310 -Gwhite@60 >> $ps << EOF
29.47 -0.55 Lake Edward
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB -Gwhite@60 >> $ps << EOF
30.3 0.00 Lake George
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB+a-8 -Gwhite@60 >> $ps << EOF
32.7 1.45 Lake Kyoga
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB+a-340 -Gwhite@60 >> $ps << EOF
32.5 1.60 Lake Kwania
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-75 -Gwhite@60 >> $ps << EOF
32.8 1.25 Victoria Nile
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-50 -Gwhite@60 >> $ps << EOF
32.57 2.8 Acuwa
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-330 -Gwhite@60 >> $ps << EOF
31.3 1.25 Kafu
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-75 -Gwhite@60 >> $ps << EOF
32.3 0.9 Lugo
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,26,blue2+jLB+a-295 -Gwhite@60 >> $ps << EOF
31.43 3.05 Albert Nile
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-280 >> $ps << EOF
34.15 3.15 Dopeh
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-330 -Gwhite@60 >> $ps << EOF
34.1 2.45 Oker
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,26,blue2+jLB+a-350 -Gwhite@60 >> $ps << EOF
30.65 0.25 Katonga
EOF

# Mts
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,black+jLB -Gwhite@40 >> $ps << EOF
30.0 0.38 Rwenzori
30.0 0.25 Mts
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,26,black+jLB -Gwhite@40 >> $ps << EOF
34.5 1.40 Mt
34.5 1.28 Elgon
EOF
# countries
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
34.4 3.8 K E N Y A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
34.2 0.1 K  E  N  Y  A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
29.3 2.3 D. R. C O N G O
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
30.6 -1.30 T A N Z A N I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f8p,25,black+jLB -Gwhite@60 >> $ps << EOF
30.1 -1.5 RWANDA
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f9p,25,black+jLB -Gwhite@60 >> $ps << EOF
30.85 4.1 S O U T H   S U D A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f14p,25,black+jLB -Gwhite@60 >> $ps << EOF
32.35 2.02 U   G   A   N   D   A
EOF

# Add GMT logo
gmt logo -Dx7.2/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y9.5c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
1.0 9.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA.
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_UG.ps -A0.5c -E720 -Tj -Z
