library(showtext)
library(hexSticker)
font_add_google("Noto Sans JP", "sans-serif")
## Automatically use showtext to render text for future devices
showtext_auto()

img<-system.file('inst','logo','boxing2.png', package = 'bpcs')

plot(sticker(img,
             package="bpcs",
             p_size=8,
             p_y=1.55,
             p_color = "#EBEBEB",
             s_x=1,
             s_y=0.8,
             s_width=0.6,
             s_height =0.6,
             h_fill="#525252",
             h_color="#1F1F1F",
             filename="inst/logo/logo.png"))



