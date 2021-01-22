#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Ethiopia)
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
gmt img2grd grav_27.1.img -R33/48/3/15 -Ggrav.grd -T1 -I1 -E -S0.1 -V
gmt grdcut grav.grd -R33/48/3/15 -Get_grav.nc
gdalinfo -stats et_grav.nc
# Minimum=-107.741, Maximum=360.996
gmt makecpt -Chaxby -T-100/100/1 > colors.cpt
# gmt makecpt --help

ps=Grav_ET.ps
# Make raster image
gmt grdimage et_grav.nc -Ccolors.cpt -R33/48/3/15 -JM6.5i -I+a15+ne0.75 -Xc -K > $ps

# Add legend
gmt psscale -Dg31.5/3+w13.3c/0.15i+v+o0.0/0i+ml+e -R -J -Ccolors.cpt \
	--FONT_LABEL=7p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg25f1a25+l"Color scale 'haxby' (Dark to light blue, white, yellow and red [C=RGB] -183/278/1)" \
	-I0.2 -By+lmGal -O -K >> $ps
    
# Add isolines
gmt grdcontour et_grav.nc -R -J -C50 -A100 -Wthinnest -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,white -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_AXES=wESN \
    --MAP_ANNOT_OBLIQUE=32 \
    --MAP_FRAME_TYPE=fancy+ \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg1f0.5a1 -Bpyg1f0.5a1 -Bsxg2 -Bsyg1 \
    -B+t"Free-air gravity anomaly for Ethiopia" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx14.5c/-1.5c+c50+w200k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-40p -O -K >> $ps

gmt psbasemap -R -J \
    --FONT_TITLE=7p,0,white \
    --MAP_TITLE_OFFSET=0.1c \
    -Tdx1.0c/0.4c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps

# Texts

# Add GMT logo
gmt logo -Dx7.0/-2.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.1c -Y8.0c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
3.0 9.3 Global satellite derived gravity grid (CryoSat-2 and Jason-1).
EOF

# Convert to image file using GhostScript
gmt psconvert Grav_ET.ps -A0.5c -E720 -Tj -Z
