#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO dataset (here: Bulgaria)
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

gmt img2grd grav_27.1.img -R2.0/29.0/41.0/44.5 -GgravBG.grd -T1 -I1 -E -S0.1 -V

gdalinfo gravBG.grd -stats
# Minimum=-575.846, Maximum=254.342
# Make color palette
# gmt makecpt --help
#gmt makecpt -Cseis.cpt -V -T-575/370/1 > colors.cpt
gmt makecpt -Cseis.cpt -V -T-576/255/10 > colors.cpt

# Generate a file
ps=Grav_BG.ps
# Make raster image
gmt grdimage gravBG.grd -Cseis -R22.0/29.0/41.0/44.5 -JM6.5i -P -I+a15+ne0.75 -Xc -K > $ps
#gmt grdimage gravBG.grd -Ccolors.cpt -R22.0/29.0/41.0/44.5 -JM6.5i -P -I+a15+ne0.75 -Xc -K > $ps

# Add grid
gmt psbasemap -R -J \
    -Bpx4f0.5a1 -Bpyg4f0.5a1 -Bsxg2 -Bsyg2 \
    --MAP_TITLE_OFFSET=0.8c \
    --MAP_FRAME_AXES=wESN \
    --FONT_TITLE=12p,Helvetica,black \
    -B+t"Free-air gravity anomaly in Bulgaria" -O -K >> $ps
    
# Add shorelines
gmt grdcontour gravBG.grd -R -J -C10 -W0.1p -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=9p,Helvetica,black \
    --MAP_TITLE_OFFSET=0.3c \
    -Lx13.0c/-1.3c+c50+w150k+l"Mercator projection. Scale: km"+f \
    -UBL/-5p/-40p -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinnest,blue -Na -N1/thinner,red -Wthin -Df -O -K >> $ps

# Add legend
gmt psscale -Dg21.2/41.0+w11.0c/0.4c+v+o0.3/0i+ml+e -R -J -Cseis \
    --FONT_LABEL=6p,Helvetica,dimgray \
    --FONT_ANNOT_PRIMARY=6p,Helvetica,black \
    -Baf+l"Color scale R-O-Y-G-B seismic tomography colors [C=RGB]" \
    -I0.2 -By+lm -O -K >> $ps

# Add GMT logo
gmt logo -Dx6.2/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y6.0c -N -O \
    -F+f10p,Helvetica,black+jLB >> $ps << EOF
3.5 9.0 Satellite derived gravity grid (CryoSat-2 and Jason-1)
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_BG.ps -A0.5c -E720 -Tj -Z
