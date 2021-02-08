#!/bin/sh
# Purpose: shaded relief grid raster map from the GEBCO 15 arc sec global data set (here: Ghana)
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
gmt img2grd curv_27.1.img -R-4/2/4/12 -Ggrav_v.grd -T1 -I1 -E -S0.1 -V
gmt grdcut grav_v.grd -R-4/2/4/12 -Ggh_grav_v.nc
gdalinfo -stats gh_grav_v.nc
# Minimum=-126.055, Maximum=157.265, Mean=0.267, StdDev=12.482
gmt makecpt -Cseis -T-50/50/1 -Ic > colors.cpt
# gmt makecpt --help seis

ps=Curv_GH.ps
# Make raster image
gmt grdimage gh_grav_v.nc -Ccolors.cpt -R-4/2/4/12 -JM5.0i -I+a15+ne0.75 -Xc -P -K > $ps

# Add legend
gmt psscale -Dg-4/3.4+w12.0c/0.15i+h+o0.3/0i+ml+e -R -J -Ccolors.cpt \
	--FONT_LABEL=8p,0,black \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_TITLE=6p,0,black \
	-Bg10f1a10+l"Color scale 'seis' (R-O-Y-G-B seismic tomography colors [C=RGB -T-50/50/1])" \
	-I0.2 -By+lmGal -O -K >> $ps
    
# Add isolines
gmt grdcontour gh_grav_v.nc -R -J -C10 -A20 -Wthinnest -O -K >> $ps

# Add coastlines, borders, rivers
gmt pscoast -R -J -P \
    -Ia/thinner,blue -Na -N1/thickest,purple -W0.1p -Df -O -K >> $ps
    
# Add grid
gmt psbasemap -R -J \
    --FORMAT_GEO_MAP=ddd:mm:ssF \
    --MAP_FRAME_AXES=WEsN \
    --MAP_TITLE_OFFSET=1.0c \
    --FONT_ANNOT_PRIMARY=7p,0,black \
    --FONT_LABEL=7p,25,black \
    --FONT_TITLE=13p,13,black \
    -Bpxg2f1a0.5 -Bpyg2f1a1 -Bsxg2 -Bsyg1 \
    -B+t"Vertical free-air gravity anomaly for Ghana" -O -K >> $ps
    
# Add scale, directional rose
gmt psbasemap -R -J \
    --FONT=7p,0,black \
    --FONT_ANNOT_PRIMARY=6p,0,black \
    --MAP_TITLE_OFFSET=0.1c \
    --MAP_ANNOT_OFFSET=0.1c \
    -Lx11.0c/-2.5c+c50+w100k+l"Mercator projection. Scale (km)"+f \
    -UBL/0p/-70p -O -K >> $ps

gmt psbasemap -R -J \
    --FONT_TITLE=7p,0,white \
    --MAP_TITLE_OFFSET=0.1c \
    -Tdx1.0c/0.4c+w0.3i+f2+l+o0.15i \
    -O -K >> $ps

# Add GMT logo
gmt logo -Dx5.0/-3.0+o0.1i/0.1i+w2c -O -K >> $ps

# Add subtitle
gmt pstext -R0/10/0/15 -JX10/10 -X0.5c -Y11.1c -N -O \
    -F+f10p,13,black+jLB >> $ps << EOF
0.5 10.3 Global satellite derived gravity grid (CryoSat-2 and Jason-1).
EOF

# Convert to image file using GhostScript
gmt psconvert Curv_GH.ps -A0.5c -E720 -Tj -Z
