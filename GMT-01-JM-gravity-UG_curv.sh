#!/bin/sh
# Purpose: geoid of Uganda
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

# Add GMT logo
gmt logo -Dx7.2/-3.1+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y9.5c -N -O \
    -F+f10p,25,black+jLB >> $ps << EOF
1.0 9.0 Global gravity grid from CryoSat-2 and Jason-1, 1 min resolution, SIO, NOAA, NGA.
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_UG.ps -A0.5c -E720 -Tj -Z
