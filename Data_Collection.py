import spotipy
from spotipy.oauth2 import SpotifyClientCredentials
import pandas as pd
import numpy as np
import time

#Accessing Authorized spotified data using the following credentials
account=open("Account_info.txt", "r")
content=account.read().split("\n")
cid=content[0].split(":")[1].strip()
secret=content[1].split(":")[1].strip()

#Creating a spotify object to access API
client_credentials_manager=SpotifyClientCredentials(client_id=cid, client_secret=secret)
sp=spotipy.Spotify(client_credentials_manager = client_credentials_manager)

#Getting information regarding artists profile on spotify
def artist_profile(name):
    return sp.search(name)

#Accessing the artists Uniform Resource Identifier (URI)
def get_uri(artist):
    return artist["tracks"]["items"][0]["artists"][0]['uri']

#Grabbing all of the artists albums
def artist_albums(artist_uri):
    return sp.artist_albums(artist_uri, album_type='album', limit=50)

#Collecting album names and uri's
def album_names(albums):
    album_name = []
    album_uri = []
    for i in range(len(albums['items'])):
        album_name.append(albums['items'][i]['name'])
        album_uri.append(albums['items'][i]['uri'])
    return album_name,album_uri

#Collecting track information
def track_info(album_name,album_uri):
    album_tracks=[]
    for m in range(len(album_uri)):
        tracks=sp.album_tracks(album_uri[m])
        album_info = {}
        album_info["Album"]=[]
        album_info['Track_Number']=[]
        album_info['id']=[]
        album_info['Name']=[]
        album_info['uri']=[]
        for n in range(len(tracks['items'])):
            album_info['Album'].append(album_name[m])
            album_info['Track_Number'].append(tracks['items'][n]['track_number'])
            album_info['id'].append(tracks['items'][n]['id'])
            album_info['Name'].append(tracks['items'][n]['name'])
            album_info['uri'].append(tracks['items'][n]['uri'])
        album_tracks.append(album_info)
    return album_tracks

#Getting the audio features of each track
def get_audio_features(album_tracks):

    #Delay so the api does not get overloaded
    time.sleep(np.random.uniform(5))

    for album in album_tracks:
        album['Acousticness']=[]
        album['Danceability'] = []
        album['Energy'] = []
        album['Instrumentalness'] = []
        album['Liveness'] = []
        album['Loudness'] = []
        album['Speechiness'] = []
        album['Tempo'] = []
        album['Valence'] = []
        album['Popularity'] = []
        for track in album["uri"]:
            features = sp.audio_features(track)
            pop=sp.track(track)
            album['Acousticness'].append(features[0]['acousticness'])
            album['Danceability'].append(features[0]['danceability'])
            album['Energy'].append(features[0]['energy'])
            album['Instrumentalness'].append(features[0]['instrumentalness'])
            album['Liveness'].append(features[0]['liveness'])
            album['Loudness'].append(features[0]['loudness'])
            album['Speechiness'].append(features[0]['speechiness'])
            album['Tempo'].append(features[0]['tempo'])
            album['Valence'].append(features[0]['valence'])
            album['Popularity'].append(pop['popularity'])

#converting the dictionaries to dataframes
def dict_to_df(album_tracks):
    artist_df = pd.DataFrame()
    for album in album_tracks:
        df = pd.DataFrame.from_dict(album, orient='index').transpose()
        artist_df=pd.concat([artist_df,df])
    return artist_df


Em=artist_profile("Eminem")
Fifty=artist_profile("50 Cent")
G_Eazy=artist_profile("G-Eazy")
Logic=artist_profile("Logic")

Em_uri=get_uri(Em)
Fifty_uri=get_uri(Fifty)
G_Eazy_uri=get_uri(G_Eazy)
Logic_uri=get_uri(Logic)

Em_albums=artist_albums(Em_uri)
Fifty_albums=artist_albums(Fifty_uri)
G_Eazy_albums=artist_albums(G_Eazy_uri)
Logic_albums=artist_albums(Logic_uri)

Em_album_names, Em_album_uri = album_names(Em_albums)
Fifty_album_names, Fifty_album_uri=album_names(Fifty_albums)
G_Eazy_album_names, G_Eazy_album_uri= album_names(G_Eazy_albums)
Logic_album_names, Logic_album_uri= album_names(Logic_albums)

Em_album_tracks=track_info(Em_album_names,Em_album_uri)
Fifty_album_tracks=track_info(Fifty_album_names,Fifty_album_uri)
G_Eazy_album_tracks=track_info(G_Eazy_album_names,G_Eazy_album_uri)
Logic_album_tracks=track_info(Logic_album_names,Logic_album_uri)

get_audio_features(Em_album_tracks)
get_audio_features(Fifty_album_tracks)
get_audio_features(G_Eazy_album_tracks)
get_audio_features(Logic_album_tracks)

Em_df=dict_to_df(Em_album_tracks)
Fifty_df=dict_to_df(Fifty_album_tracks)
G_Eazy_df=dict_to_df(G_Eazy_album_tracks)
Logic_df=dict_to_df(Logic_album_tracks)

#Storing Data in txt files
Em_df.to_csv("Em.txt",encoding='utf-8', index=False)
Fifty_df.to_csv("Fifty.txt",encoding='utf-8', index=False)
G_Eazy_df.to_csv("G_Eazy.txt",encoding='utf-8', index=False)
Logic_df.to_csv("Logic.txt",encoding='utf-8', index=False)