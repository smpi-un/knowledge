
## カードデザイン
Google Colabで作成。

### ソース
```js
{
  "cells": [
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "colab": {
          "background_save": true
        },
        "id": "0LKekV6SnCVu"
      },
      "outputs": [],
      "source": [
        "!wget https://fonts.gstatic.com/s/lobster/v23/neILzCirqoswsqX9zo-mM5Ez.woff\n",
        "!mv neILzCirqoswsqX9zo-mM5Ez.woff /usr/share/fonts/truetype/\n",
        "!fc-cache -fv"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "colab": {
          "background_save": true
        },
        "id": "F5TUktzyqBOB"
      },
      "outputs": [],
      "source": [
        "\n",
        "from PIL import Image, ImageDraw, ImageFont\n",
        "import requests\n",
        "from io import BytesIO\n",
        "from IPython.display import display"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "colab": {
          "background_save": true
        },
        "id": "Ylsa58oaqDDq"
      },
      "outputs": [],
      "source": [
        "\n",
        "class Colors:\n",
        "  def __init__(self, text_color, background_color,  name_color):\n",
        "    self.background_color = background_color\n",
        "    self.text_color = text_color\n",
        "    self.name_color = name_color\n"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "colab": {
          "background_save": true
        },
        "id": "bVOsIgs0qEXt"
      },
      "outputs": [],
      "source": [
        "\n",
        "# 名刺のサイズと色を設定\n",
        "scale = 10\n",
        "card_width_mm, card_height_mm = 86.6, 54.0\n",
        "\n",
        "# ミリメートルをインチに変換\n",
        "width_inch = card_width_mm / 25.4\n",
        "height_inch = card_height_mm / 25.4\n",
        "\n",
        "# インチを96 DPIのピクセルに変換\n",
        "card_width = int(round(width_inch * 96))\n",
        "card_height = int(round(height_inch * 96))\n",
        "\n",
        "text_font_size = 480\n"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "colab": {
          "background_save": true
        },
        "id": "PbkdumCMqq8m"
      },
      "outputs": [],
      "source": [
        "\n",
        "#background_color = '#3D9970'  # オリーブグリーン\n",
        "#text_color = '#001F3F'  # 紺色\n",
        "an1 = Colors(\n",
        "  text_color = '#3D9970',  # オリーブグリーン\n",
        "  background_color = '#001F3F',  # 紺色\n",
        "  name_color = '#85144B',  # マルーン\n",
        ")\n",
        "an2 = Colors(\n",
        "  text_color = '#F8F0E5',\n",
        "  background_color = '#001F3F',  # 紺色\n",
        "  name_color = '#85144B',  # マルーン\n",
        ")\n",
        "\n",
        "an3 = Colors(\n",
        "  '#EADBC8', '#DAC0A3', '#0F2C59'\n",
        ")\n",
        "# https://colorhunt.co/palette/222831393e4600adb5eeeeee\n",
        "an4 = Colors(\n",
        "  '#222831', '#393E46', '#00ADB5'\n",
        ")\n",
        "# https://colorhunt.co/palette/f6f5f5d3e0ea1687a7276678\n",
        "an5 = Colors(\n",
        "  '#F6F5F5', '#D3E0EA', '#1687A7'\n",
        ")\n",
        "# https://colorhunt.co/palette/232931393e464ecca3eeeeee\n",
        "an6 = Colors(\n",
        "  '#393E46', '#232931', '#4ECCA3'\n",
        ")\n",
        "# https://colorhunt.co/palette/f0f5f9c9d6df52616b1e2022\n",
        "an7 = Colors(\n",
        "  '#F0F5F9', '#C9D6DF', '#1E2022'\n",
        ")\n",
        "an8 = Colors(\n",
        "  '#F0F5F9', '#C9D6DF', '#52616B'\n",
        ")\n",
        "# https://colorhunt.co/palette/fffbeb495579263159251749\n",
        "an8 = Colors(\n",
        "  '#251749', '#263159', '#FFFBEB'\n",
        ")\n",
        "# https://colorhunt.co/palette/ff8787f8c4b4e5ebb2bce29e\n",
        "an8 = Colors(\n",
        "  '#BCE29E', '#E5EBB2', '#FF8787'\n",
        ")\n",
        "# プレイリーカード公式青\n",
        "p_blue = Colors(\n",
        "  '#7987AD', '#6D7A9F', '#FFFFFF'\n",
        ")\n",
        "# 白黒\n",
        "p_mono = Colors(\n",
        "  '#000000', '#FFFFFF', '#FFFFFF'\n",
        ")\n",
        "colors = p_mono"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "colab": {
          "background_save": true
        },
        "id": "OR50XrHXqvUD"
      },
      "outputs": [],
      "source": [
        "\n",
        "name = 'SHIMPEI UENO'\n",
        "name = 'Shimpei Ueno'"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "id": "wnBaX_2Orqeg"
      },
      "outputs": [],
      "source": [
        "# Google Colabで動作する名刺作成プログラム\n",
        "from PIL import Image, ImageDraw, ImageOps, ImageFont\n",
        "\n",
        "import numpy as np\n",
        "\n",
        "\n",
        "# フォントファイルをダウンロード\n",
        "url = 'https://github.com/googlefonts/noto-cjk/blob/main/Sans/OTF/Japanese/NotoSansCJKjp-Bold.otf?raw=true'\n",
        "font_data = requests.get(url).content\n",
        "\n",
        "\n",
        "def create_image(color1, color2, scale, is_inv):\n",
        "\n",
        "    def inv(nparr):\n",
        "            # 結果を画像化\n",
        "            srcimg = Image.fromarray((nparr * 255).astype(np.uint8))\n",
        "\n",
        "            # 色の反転\n",
        "            dstimg = ImageOps.invert(srcimg.convert('RGB'))\n",
        "\n",
        "            # 画像をnumpy配列に変換\n",
        "            dstnparr = np.array(dstimg)[:, :, :3].astype(np.float32) / 255.0\n",
        "\n",
        "            return dstnparr\n",
        "\n",
        "\n",
        "    def draw_text(img, text, rot, size, offset):\n",
        "        # フォントオブジェクトを作成\n",
        "        font = ImageFont.truetype(BytesIO(font_data), size*scale)\n",
        "        text_img = Image.new('RGB', (img.width*2, img.height*2), color2)\n",
        "        text_draw = ImageDraw.Draw(text_img)\n",
        "        dx, dy, textwidth, textheight = text_draw.textbbox((0, 0), text, font)\n",
        "        print(text_draw.textbbox((0, 0), text, font))\n",
        "        position = ((text_img.width-textwidth - dx)/2 + offset[0]*scale, (text_img.height-textheight - dy)/2 + offset[1]*scale)\n",
        "        text_draw.text(position, 'ぬ', fill=color1, font=font)\n",
        "\n",
        "        # 画像を指定された角度で回転し、余白をトリミング\n",
        "        rotate_img = text_img.rotate(rot, resample=Image.BICUBIC, expand=True)\n",
        "        # rotate_draw = ImageDraw.Draw(rotate_img)\n",
        "\n",
        "        # rotate_img = rotate_img.crop(rotate_img.getbbox())\n",
        "        # テキストラベルを既存の画像に貼り付け （例ではs中央に配置）\n",
        "        print((img.width, img.height))\n",
        "        print((text_img.width, text_img.height))\n",
        "        print((rotate_img.width, rotate_img.height))\n",
        "        position = ((img.width-rotate_img.width)//2, (img.height-rotate_img.height)//2)\n",
        "        img.paste(rotate_img, position)\n",
        "        return\n",
        "\n",
        "    # 画像を作成\n",
        "    img1 = Image.new('RGB', (card_width*scale, card_height*scale), color2)\n",
        "    img2 = Image.new('RGB', (card_width*scale, card_height*scale), color2)\n",
        "    draw1 = ImageDraw.Draw(img1)\n",
        "    draw2 = ImageDraw.Draw(img2)\n",
        "\n",
        "    # 「ぬ」の文字を描く\n",
        "    draw_text(img1, 'ぬ', 6, 370, (0, 0))\n",
        "#     draw1.text((-80*scale, -330*scale), 'ぬ', fill=color1, font=font)\n",
        "\n",
        "    # 名前を描く（小さなフォントで）\n",
        "    font_small = ImageFont.truetype(BytesIO(font_data), 18*scale)\n",
        "    # draw1.text((240*scale, 170*scale), name, fill=color2, font=font_small)\n",
        "    draw2.text((182*scale, 170*scale), name, fill=color1, font=font_small)\n",
        "\n",
        "    # 画像をnumpy配列に変換（まずはRGB成分のみを使用）\n",
        "    img1_np = np.array(img1)[:, :, :3].astype(np.float32) / 255.0\n",
        "    img2_np = np.array(img2)[:, :, :3].astype(np.float32) / 255.0\n",
        "\n",
        "    # 乗算ブレンド\n",
        "    blend_np = (img1_np * img2_np + inv(img1_np)) * (img1_np + inv(img2_np))\n",
        "\n",
        "    # 結果を画像化し戻り値とする\n",
        "    if is_inv:\n",
        "        return Image.fromarray((inv(blend_np) * 255).astype(np.uint8))\n",
        "    else:\n",
        "        return Image.fromarray((blend_np * 255).astype(np.uint8))\n",
        "\n",
        "\n",
        "\n",
        "image = create_image( '#000000', '#FFFFFF', 12, True)\n",
        "# 画像を表示\n",
        "display(image)\n",
        "image.save(\"/home/img.png\")"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "id": "4u0C5dDTlem9"
      },
      "outputs": [],
      "source": []
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "id": "_y083D-H3F3h"
      },
      "outputs": [],
      "source": [
        "!pip install svgwrite\n",
        "\n",
        "import svgwrite\n",
        "from IPython.display import SVG, display\n",
        "\n",
        "def create_svg(colors):\n",
        "    font_family = 'Lobster'\n",
        "    # font_family = \"Noto Sans\"\n",
        "    dwg = svgwrite.Drawing('test.svg', size=(card_width*scale, card_height*scale))\n",
        "\n",
        "    # 背景色を描画\n",
        "    dwg.add(dwg.rect(insert=(0, 0), size=(card_width*scale, card_height*scale), fill=colors.background_color))\n",
        "\n",
        "    # 「ぬ」の文字を描く\n",
        "    dwg.add(dwg.text('ぬ',\n",
        "                     insert=(card_width*scale/2, card_height*scale/2),\n",
        "                     fill=colors.text_color,\n",
        "                     font_family=font_family,\n",
        "                     font_size=f\"{text_font_size*scale}px\",\n",
        "                     dominant_baseline=\"middle\",\n",
        "                     text_anchor=\"middle\",\n",
        "                     font_weight=\"bold\",\n",
        "                     transform=\"rotate({0}, {1}, {2})\".format(-6, card_width*scale/2, card_height*scale/2),\n",
        "    ))\n",
        "\n",
        "    # 名前を描く\n",
        "    dwg.add(dwg.text(\n",
        "        name,\n",
        "        insert=((card_width - 20)*scale, (card_height - 10)*scale),\n",
        "        fill=colors.name_color,\n",
        "        font_family=\"Noto Sans\",\n",
        "        font_size=f\"{12*scale}px\",\n",
        "        text_anchor=\"end\",\n",
        "    ))\n",
        "\n",
        "    return dwg\n",
        "\n",
        "dwg = create_svg(colors)\n",
        "\n",
        "# 表示\n",
        "display(SVG(dwg.tostring()))"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "id": "GEfAhGyclPr2"
      },
      "outputs": [],
      "source": [
        "\n",
        "\n",
        "# SVGファイルとして保存\n",
        "file_name = \"business_card.svg\"\n",
        "dwg.saveas(file_name)\n",
        "\n",
        "# Google Colabからのダウンロードリンクを提供\n",
        "from google.colab import files\n",
        "files.download(file_name)\n"
      ]
    },
    {
      "cell_type": "code",
      "execution_count": null,
      "metadata": {
        "colab": {
          "background_save": true
        },
        "id": "1uIMmyL9mqK9"
      },
      "outputs": [],
      "source": [
        "!pip install svgwrite\n",
        "\n",
        "import svgwrite\n",
        "from IPython.display import SVG, display\n",
        "from lxml import etree\n",
        "\n",
        "\n",
        "def create_svg(colors, scale):\n",
        "    font_family = 'Lobster'\n",
        "    # font_family = \"Noto Sans\"\n",
        "    dwg = svgwrite.Drawing('test.svg', size=(card_width*scale, card_height*scale))\n",
        "\n",
        "    # 背景色を描画\n",
        "    dwg.add(dwg.rect(insert=(0, 0), size=(card_width*scale, card_height*scale), fill=colors.background_color))\n",
        "\n",
        "    # 「ぬ」の文字を描く\n",
        "    dwg.add(dwg.text('ぬ',\n",
        "                     insert=(card_width*scale/2, card_height*scale/2),\n",
        "                     fill=colors.text_color,\n",
        "                     font_family=font_family,\n",
        "                     font_size=f\"{text_font_size*scale}px\",\n",
        "                     dominant_baseline=\"middle\",\n",
        "                     text_anchor=\"middle\",\n",
        "                     font_weight=\"bold\",\n",
        "                     transform=\"rotate({0}, {1}, {2})\".format(-6, card_width*scale/2, card_height*scale/2),\n",
        "    ))\n",
        "\n",
        "\n",
        "    blend = etree.Element('{http://www.w3.org/2000/svg}feBlend', attrib={'mode': 'multiply',\n",
        "                                                                          'in': 'SourceGraphic',\n",
        "                                                                          'in2': 'BackgroundImage'})\n",
        "    filter = etree.Element('{http://www.w3.org/2000/svg}filter', attrib={'id': 'multiply'})\n",
        "    filter.append(blend)\n",
        "    dwg.get_xml().append(filter)\n",
        "\n",
        "    # 名前を描く\n",
        "    dwg.add(dwg.text(\n",
        "        name,\n",
        "        insert=((card_width - 20)*scale, (card_height - 20)*scale),\n",
        "        fill=colors.name_color,\n",
        "        font_family=\"Noto Sans\",\n",
        "        font_size=f\"{12*scale}px\",\n",
        "        text_anchor=\"end\",\n",
        "    ))\n",
        "\n",
        "    return dwg\n",
        "\n",
        "dwg = create_svg(colors, 2)\n",
        "\n",
        "# 表示\n",
        "display(SVG(dwg.tostring()))"
      ]
    }
  ],
  "metadata": {
    "colab": {
      "provenance": []
    },
    "kernelspec": {
      "display_name": "Python 3",
      "name": "python3"
    },
    "language_info": {
      "name": "python"
    }
  },
  "nbformat": 4,
  "nbformat_minor": 0
}
```