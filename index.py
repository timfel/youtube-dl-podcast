import glob
import html
import json
import os
import sys


if len(sys.argv) < 3:
    print(f"Usage: {sys.argv[0]} dataPath feedUrl")
    exit(1)

basepath = sys.argv[1]
baseUrl = sys.argv[2]

dataglob = os.path.join(basepath, "data", "*.info.json")
print(dataglob, "->", baseUrl)

indexfile = os.path.join(basepath, "index.html")

output  = [f"""
<rss xmlns:content="http://purl.org/rss/1.0/modules/content/" xmlns:wfw="http://wellformedweb.org/CommentAPI/" xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:atom="http://www.w3.org/2005/Atom" xmlns:sy="http://purl.org/rss/1.0/modules/syndication/" xmlns:slash="http://purl.org/rss/1.0/modules/slash/" xmlns:itunes="http://www.itunes.com/dtds/podcast-1.0.dtd" xmlns:rawvoice="http://www.rawvoice.com/rawvoiceRssModule/" version="2.0">
<channel>
<title>Podcast dump</title>
<description>Podcast feed from occasionally downloaded files.</description>
<link>{baseUrl}/</link>
<image>
  <url>{baseUrl}/podcasts.jpg</url>
  <title>Podcast dump</title>
  <link>{baseUrl}/</link>
</image>
<itunes:image href="{baseUrl}/podcasts.jpg"/>'
"""]

for f in glob.glob(dataglob):
    print(f, end=": ")
    with open(f) as fp:
        js = json.load(fp)
        link = f"{baseUrl}/data/{js['id']}.mp3"
        image = f"{baseUrl}/data/{js['id']}.jpg"

        output += [f"""
        <item>
        <title>{html.escape(js['title'])}</title>
        <description>{html.escape(js['description'])}</description>
        <link>{link}</link>
        <enclosure url="{link}" length="{js['filesize']}" type="audio/mpeg"/>
        """]
        # if js.get('upload_date', None):
        #     output += [f"<pubDate>{json['upload_date']}</pubDate>"]
        output += [f"""
        <itunes:duration>{js['duration']}</itunes:duration>
        <itunes:image href="{image}" />'
        </item>
        """]
        print(js['title'])

output += ["""
</channel>
</rss>
"""]

with open(indexfile, "w") as outfile:
    outfile.write("\n".join(output))
