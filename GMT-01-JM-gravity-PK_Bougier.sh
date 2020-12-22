#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Pakistan)
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
    FONT_ANNOT_PRIMARY=7p,Helvetica,dimgray \
    FONT_LABEL=7p,Helvetica,dimgray
# Overwrite defaults of GMT
gmtdefaults -D > .gmtdefaults

gmt img2grd curv_27.1.img  -R60.0/80.0/23.5/37.2 -GgravPK_B.grd -T1 -I1 -E -S0.1 -V
gdalinfo gravPK_B.grd -stats
# Minimum: -806.057, Maximum=1069.952

# Generate a color palette table from grid
# gmt makecpt -Cturbo -T-288/487/1 > colors.cpt
gmt makecpt -Cseis -T-8067/1070/100 -Ic > colors1.cpt
gmt makecpt -Cseis -T-100/200/10 -Ic > colors.cpt
# -Ic

gmt grd2cpt gravPK_B.grd -L0/400 -S-200/200/10 -Chaxby > mydata.cpt
# -L0/500
#

# Generate a file
ps=Grav_PK.ps
gmt grdimage gravPK_B.grd -Cmydata.cpt -R60.0/80.0/23.5/37.2 -JM6.5i -P -I+a15+ne0.75 -Xc -K > $ps

gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WESN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -Bpxg2f1a2 -Bpyg2f1a2 -Bsxg2 -Bsyg1 \
    -B+t"Bouguer gravity anomaly for Pakistan" \
    -Lx14.0c/-2.5c+c318/-57+w300k+l"Mercator projection. Scale: km"+f \
    -UBL/0p/-70p -O -K >> $ps

# Add isolines
gmt grdcontour gravPK_B.grd -R -J -C500 -W0.1p -O -K >> $ps

# Add legend
gmt psscale -Dg60.0/22.0+w16.0c/0.15i+h+o0.3/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=7p,Helvetica,black \
    --FONT_ANNOT_PRIMARY=7p,Helvetica,black \
    --FONT_TITLE=6p,Helvetica,black \
    --MAP_ANNOT_OFFSET=0.1c \
    -Bg40f5a20+l"Color palette: Bill Haxby's color scheme for geoid & gravity [C=RGB]" \
    -I0.2 -By+lmGal -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thickest,red -Wthinner -Df -O -K >> $ps

# Texts
gmt pstext -R -J -N -O -K \
-F+f11p,Times-Roman,black+jLB -Gwhite@30 >> $ps << EOF
67.3 24.6 Karachi
EOF
gmt psxy -R -J -Sc -W0.5p -Gyellow -O -K << EOF >> $ps
67.3 24.4 0.15c
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f12p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
69.0 30.5 P A K I S T A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
75.0 27.5 I N D I A
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
64.0 33.5 A F G H A N I S T A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
60.5 27.5 I R A N
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f10p,Helvetica,black+jLB -Gwhite@40 -Wthinnest >> $ps << EOF
77.0 36.5 CHINA
EOF

gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Times−Italic,blue+jLB+a-324 >> $ps << EOF
68.7 28.0 Indus River
EOF
gmt pstext -R -J -N -O -K \
-F+jTL+f11p,Helvetica,yellow+jLB >> $ps << EOF
60.6 24.2  A r a b i a n  S e a
EOF

# Add GMT logo
gmt logo -Dx7.0/-3.2+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y8.0c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
1.0 8.9 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA.
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_PK.ps -A0.5c -E720 -Tj -Z
