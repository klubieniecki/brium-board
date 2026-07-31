import numpy as np, re
from matplotlib.textpath import TextPath
from matplotlib.font_manager import FontProperties

INK="#152834"; SUN="#E5913A"; SEA="#2F7D89"; PAPER="#FBF7F0"

# ---------- board profile ----------
BL,BW,EF,RC=610,360,128,60
L,W,A=BL/2,BW/2,EF/2
R=((L-RC)**2+(W-A)**2-RC**2)/(2*(W-A-RC)); CY=W-R; CCX,CCY=L-RC,A
TH=np.degrees(np.arctan2(CCY-CY,CCX))
t1=np.radians(np.linspace(0,TH,90)); t2=np.radians(np.linspace(TH,90,180))
q=np.vstack([[[L,0]],np.c_[CCX+RC*np.cos(t1),CCY+RC*np.sin(t1)],np.c_[R*np.cos(t2),CY+R*np.sin(t2)]])
OUT=np.vstack([q,np.c_[-q[::-1,0],q[::-1,1]],np.c_[-q[:,0],-q[:,1]],np.c_[q[::-1,0],-q[::-1,1]]])

def board(sx,rot,dx,dy,fill,grow=0,sq=0.175):
    pts=OUT*(1+grow/305.0); a=np.radians(rot); c,s=np.cos(a),np.sin(a)
    p=pts*np.array([sx,sx*sq]); p=np.c_[p[:,0]*c-p[:,1]*s,p[:,0]*s+p[:,1]*c]+np.array([dx,dy])
    return '<path d="M '+" L ".join(f"{x:.2f} {y:.2f}" for x,y in p)+f' Z" fill="{fill}"/>'

def mark_primary(mono=False, cx=120, cy=120, k=1.0, fg=INK, bg=PAPER):
    sun = fg if mono else SUN
    return (f'<circle cx="{cx}" cy="{cy+14*k}" r="{68*k}" fill="{sun}"/>'
            + board(0.30*k,-11,cx,cy-14*k,bg,15)
            + board(0.30*k,-11,cx,cy-14*k,fg))

def mark_roundel(mono=False, fg=INK, bg=PAPER):
    # in mono the wave is dropped - sun + sea + board all in one colour turns to mush
    sun = fg if mono else SUN
    wave = "" if mono else f'<path d="M 8 172 Q 64 154 120 172 T 232 172 L 232 232 L 8 232 Z" fill="{SEA}"/>'
    return f'''<circle cx="120" cy="120" r="101" fill="none" stroke="{fg}" stroke-width="10"/>
<clipPath id="rc"><circle cx="120" cy="120" r="96"/></clipPath>
<g clip-path="url(#rc)">
<circle cx="120" cy="144" r="50" fill="{sun}"/>
{wave}
{board(0.25,-11,120,114,bg,16)}
{board(0.25,-11,120,114,fg)}
</g>'''

def mark_balance(mono=False, fg=INK, bg=PAPER):
    ball=fg if mono else SUN
    return (board(0.31,-12,120,110,fg)
            + f'<circle cx="120" cy="156" r="28" fill="{ball}"/>'
            + f'<line x1="46" y1="200" x2="194" y2="200" stroke="{fg}" stroke-width="9" stroke-linecap="round"/>')

# ---------- tracked wordmark, outlined ----------
FP=FontProperties(family="Latin Modern Sans", weight="bold")
def glyph(ch,size):
    tp=TextPath((0,0),ch,size=size,prop=FP); d=""
    for v,c in tp.iter_segments():
        if c==1: d+=f"M {v[0]:.2f} {-v[1]:.2f} "
        elif c==2: d+=f"L {v[0]:.2f} {-v[1]:.2f} "
        elif c==3: d+=f"Q {v[0]:.2f} {-v[1]:.2f} {v[2]:.2f} {-v[3]:.2f} "
        elif c==4: d+=f"C {v[0]:.2f} {-v[1]:.2f} {v[2]:.2f} {-v[3]:.2f} {v[4]:.2f} {-v[5]:.2f} "
        elif c==79: d+="Z "
    e=tp.get_extents(); return d, e.x0, e.x1, e.y0, e.y1

def shift(d,dx,dy):
    out=[];toks=d.split()
    i=0
    while i<len(toks):
        t=toks[i]
        if t in "MLQCZ":
            out.append(t); n={"M":2,"L":2,"Q":4,"C":6,"Z":0}[t]
            for j in range(n//2):
                x=float(toks[i+1+2*j])+dx; y=float(toks[i+2+2*j])+dy
                out += [f"{x:.2f}", f"{y:.2f}"]
            i+=1+n
        else: i+=1
    return " ".join(out)

def wordmark(text,size=100,track=0.10,color=INK):
    ds=[]; x=0; ymin=1e9; ymax=-1e9
    for ch in text:
        d,x0,x1,y0,y1=glyph(ch,size)
        ds.append(shift(d,x-x0,0)); x += (x1-x0) + track*size
        ymin=min(ymin,-y1); ymax=max(ymax,-y0)
    x-=track*size
    return f'<path d="{" ".join(ds)}" fill="{color}"/>', x, ymin, ymax

def svg(vb,body,pad=0):
    return f'<svg xmlns="http://www.w3.org/2000/svg" viewBox="{vb}">{body}</svg>'

# ---------- files ----------
open("brium-mark.svg","w").write(svg("0 0 240 240", mark_primary(False)))
open("brium-mark-mono.svg","w").write(svg("0 0 240 240", mark_primary(True)))
open("brium-avatar.svg","w").write(svg("0 0 240 240", mark_roundel(False)))
open("brium-avatar-mono.svg","w").write(svg("0 0 240 240", mark_roundel(True)))
open("brium-mark-balance.svg","w").write(svg("0 0 240 240", mark_balance(False)))
open("brium-mark-balance-mono.svg","w").write(svg("0 0 240 240", mark_balance(True)))

# horizontal lockup
wm,ww,y0,y1 = wordmark("BRIUM",100,0.10)
# letterspace BOARD so it spans exactly the width of BRIUM
_raw=sum(glyph(c,30)[2]-glyph(c,30)[1] for c in "BOARD")
_tr=(ww-_raw)/(4*30)
sub,sw,sy0,sy1 = wordmark("BOARD",30,_tr)
capH=y1-y0
gx=270
body=(f'<g>{mark_primary(False)}</g>'
      f'<g transform="translate({gx},{120-y0-capH/2-14})">{wm}</g>'
      f'<g transform="translate({gx},{120-y0-capH/2+54})">{sub}</g>')
open("brium-logo-horizontal.svg","w").write(svg(f"0 0 {gx+max(ww,sw)+16} 240", body))

# stacked lockup
body=(f'<g transform="translate({(max(ww,sw)+40)/2-120},0)">{mark_primary(False)}</g>'
      f'<g transform="translate({(max(ww,sw)+40)/2-ww/2},{262-y0})">{wm}</g>'
      f'<g transform="translate({(max(ww,sw)+40)/2-sw/2},{262-y0+54})">{sub}</g>')
open("brium-logo-stacked.svg","w").write(svg(f"0 0 {max(ww,sw)+40} 420", body))

# wordmark alone
body=f'<g transform="translate(0,{-y0})">{wm}</g><g transform="translate(0,{-y0+54})">{sub}</g>'
open("brium-wordmark.svg","w").write(svg(f"-8 -8 {max(ww,sw)+16} {capH+76}", body))
print("built", round(ww), round(capH))


# ---------- dark-background variants ----------
open("brium-mark-dark.svg","w").write(svg("0 0 240 240", mark_primary(False, fg=PAPER, bg=INK)))
open("brium-avatar-dark.svg","w").write(svg("0 0 240 240", mark_roundel(False, fg=PAPER, bg=INK)))
wmD,_,_,_ = wordmark("BRIUM",100,0.10,color=PAPER)
subD,_,_,_ = wordmark("BOARD",30,_tr,color=PAPER)
bodyD=(f'<g>{mark_primary(False, fg=PAPER, bg=INK)}</g>'
       f'<g transform="translate({gx},{120-y0-capH/2-14})">{wmD}</g>'
       f'<g transform="translate({gx},{120-y0-capH/2+54})">{subD}</g>')
open("brium-logo-horizontal-dark.svg","w").write(svg(f"0 0 {gx+max(ww,sw)+16} 240", bodyD))
print("dark variants ok")
