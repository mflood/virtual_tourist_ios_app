
# https://www.flickr.com/services/apps/72157720882274685/

# Api and Explorer for photo search
# https://www.flickr.com/services/api/flickr.photos.search.html
# https://www.flickr.com/services/api/explore/flickr.photos.search
#
#

source .env
API_KEY="$F_API_KEY"

url="https://www.flickr.com/services/rest/?method=flickr.photos.search&api_key=$API_KEY&lat=37&lon=126&radius=10&radius_units=km&format=json&nojsoncallback=1"

curl "$url"
