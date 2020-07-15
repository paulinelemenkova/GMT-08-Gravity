#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Indian Ocean, Sunda Trench)
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

img2grd grav_27.1.img -R90/130/-20/10 -GgravST.grd -T1 -I1 -E -S0.1 -V
gdalinfo gravST.grd -stats
# -287.5250244140625,486.1010131835938


# Generate a color palette table from grid
gmt makecpt -Cturbo -T-288/487/1 > colors.cpt

# Generate a file
ps=Grav_ST.ps
gmt grdimage gravST.grd -Ccolors.cpt -R90/130/-20/10 -JM6i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx10f5a5 -Bpyg10f5a5 -Bsxg5 -Bsyg5 \
    --MAP_TITLE_OFFSET=0.8c \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    --FONT_LABEL=7p,Helvetica,black \
    -B+t"Marine free-air gravity anomaly for the Sunda Trench, Java and Sumatra region" \
    -Lx12.7c/-1.3c+c318/-57+w800k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add grid
# Add isolines
gmt grdcontour gravST.grd -R -J -C50 -W0.1p -O -K >> $ps
    
gmt psscale -Dg84.2/-20+w11.4c/0.4c+v+o0.3/0i+ml -R -J -Ccolors.cpt \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Ba50f10+l"Color scale 'turbo': Google's Improved Rainbow Colormap for Visualization [C=RGB] -288/487)" \
    -I0.2 -By+lm -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P -Ia/thinnest,blue -Na -N1/thinner,red -Wthinner -Df -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y5.7c -N -O \
    -F+f10p,Palatino-Roman,black+jLB >> $ps << EOF
0.5 10.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA.
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_ST.ps -A0.5c -E720 -Tj -Z
