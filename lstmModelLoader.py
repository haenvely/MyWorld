from __future__ import absolute_import, division, print_function, unicode_literals, unicode_literals
import pandas as pd
import numpy as np
import re
import csv
import tensorflow as tf
from numpy import array
from keras.preprocessing.text import one_hot
from keras.preprocessing.sequence import pad_sequences
from keras.models import Sequential

from keras.layers.embeddings import Embedding
from sklearn.model_selection import train_test_split
from keras.preprocessing.text import Tokenizer

from tensorflow import keras

cols = ['sentiment','id','date','query_string','user','text']
tweets = pd.read_csv("./data/sentiment140_training.1600000.processed.noemoticon.csv", encoding = 'latin-1', header = None, names = cols)
tweets.isnull().values.any()

brand = 'hyundai'

file_cols = ['date', 'time', 'user', 'text']
file = pd.read_csv("./전처리/preprocessed/전처리최종_2020{}.csv".format(brand), encoding = 'utf-8', header = None, names = file_cols)

#Data Preprocessing
def preprocess_text(sen):
    # Removing html tags
    sentence = remove_tags(sen)

    # Remove punctuations and numbers
    sentence = re.sub('[^a-zA-Z]', ' ', sentence)

    # Single character removal
    sentence = re.sub(r"\s+[a-zA-Z]\s+", ' ', sentence)

    # Removing multiple spaces
    sentence = re.sub(r'\s+', ' ', sentence)

    return sentence

TAG_RE = re.compile(r'<[^>]+>')

def remove_tags(text):
    return TAG_RE.sub('', text)

X=[]
sentences = list(tweets['text'])
for sen in sentences:
    X.append(preprocess_text(sen))
y = tweets['sentiment']

#sentiment를 긍정은 1, 부정은 0으로 수정
y = np.array(list(map(lambda x: 1 if x == 4 else 0, y)))

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20, random_state=42)

#Preparing the Embedding Layer
tokenizer = Tokenizer(num_words=5000)
tokenizer.fit_on_texts(X_train)

X_train = tokenizer.texts_to_sequences(X_train)
X_test = tokenizer.texts_to_sequences(X_test)

# Adding 1 because of reserved 0 index
vocab_size = len(tokenizer.word_index) + 1

maxlen = 69

X_train = pad_sequences(X_train, padding='post', maxlen=maxlen)
X_test = pad_sequences(X_test, padding='post', maxlen=maxlen)


new_model = keras.models.load_model('./lstm모델/DB2048_twitter100D_69_30_lstm_model.h5', compile=False)
new_model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['acc'])
new_model.summary()
loss, acc = new_model.evaluate(X_test, y_test, verbose=1)
print("복원된 모델의 정확도: {:5.2f}%".format(100*acc))

instance = []
sentences = list(file['text'])
for sen in sentences:
    sen = str(sen)
    instance.append(preprocess_text(sen))
tokenizer = Tokenizer(num_words=5000)
tokenizer.fit_on_texts(instance)
instance = tokenizer.texts_to_sequences(instance)

vocab_size = len(tokenizer.word_index) + 1
maxlen = 69

instance= pad_sequences(instance, padding='post', maxlen=maxlen)
results = new_model.predict(instance)
classes = new_model.predict_classes(instance)
print(type(results))
print(type(classes))

print(results)
print(classes)

with open('./감성결과/9일간감성결과/감성결과_2020{}.csv'.format(brand), 'w', encoding='utf-8') as f:
    for i in range(len(file)):
        f.write('{},{},{},{},{},{},{}\n'.format(i, file['date'][i], file['time'][i], file['user'][i], file['text'][i], results[i], classes[i]))
