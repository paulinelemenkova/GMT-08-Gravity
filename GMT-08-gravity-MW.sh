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
gmt img2grd grav_27.1.img -R32/36/-17.5/-9 -Ggrav.grd -T1 -I1 -E -S0.1 -V
gmt grdcut grav.grd -R32/36/-17.5/-9 -Gmw_grav.nc
gdalinfo -stats mw_grav.nc
# Minimum=-173.894, Maximum=226.063
gmt makecpt -Cjet -T-200/200/1 > colors.cpt
# gmt makecpt --help

ps=Grav_MW.ps
# Make raster image
gmt grdimage mw_grav.nc -Ccolors.cpt -R32/36/-17.5/-9 -JM5.0i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg32/-17.9+w12.0c/0.15i+h+o0.3/0i+ml+e -R -J -Ccolors.cpt \
	--FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg25f5a50+l"Color scale 'jet' (Dark to light blue, white, yellow and red [C=RGB] -183/278/1)" \
	-I0.2 -By+lmGal -O -K >> $ps
    
# Add isolines
gmt grdcontour mw_grav.nc -R -J -C10 -A50 -Wthinnest -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,red -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --MAP_FRAME_AXES=WEsN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg2f1a0.5 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Free-air gravity anomaly for Malawi" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.0c/-2.5c+c50+w50k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

gmt psbasemap -R -J \
    --FONT_TITLE=7p,0,white \
    --MAP_TITLE_OFFSET=0.1c \
    -Tdx1.0c/0.4c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx5.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y21.5c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
0.5 10.3 Global satellite derived gravity grid (CryoSat-2 and Jason-1).
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_MW.ps -A3.5c -E720 -Tj -Z
