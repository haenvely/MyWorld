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
from konlpy.tag import Komoran

mode = 'lstm'
maxlen = 30
embed = 'glove'
kor = 'Komoran'


cols = ['id', 'text', 'sentiment']
tweets = pd.read_csv("C:/Users/북미가자/Desktop/Navernews_sj/SSK_code/ratings.txt", encoding = 'utf-8', header = 0, names = cols, sep = "\t")
print(tweets.isnull().values.any())
tweets = tweets.dropna(how= "any")

#Data Preprocessing
def preprocess_text(sen):
    # Removing html tags
    sentence = remove_tags(sen)

    # Remove punctuations and numbers
    #sentence = re.sub('[^a-zA-Z]', ' ', sentence)
    sentence = re.sub('[^ㄱ-ㅎㅏ-ㅣ가-힣 ]+', ' ', sentence)

    # Single character removal
    sentence =  re.sub(r"\s+[ㄱ-ㅎㅏ-ㅣ가-힣]\s+", ' ', sentence)

    # Removing multiple spaces
    sentence = re.sub(r'\s+', ' ', sentence)

    return sentence

TAG_RE = re.compile(r'<[^>]+>')

def remove_tags(text):
    return TAG_RE.sub('', text)

komoran = Komoran(max_heap_size=1024*6)

X=[]
sentences = list(tweets['text'])
print(sentences[0:2])

for sen in sentences:
    temp_X = []
    sen = preprocess_text(str(sen))

    #temp_X = okt.morphs(sen, stem = True)
    try:
        if re.fullmatch(r'[\s]+', sen) != None:
            sen = "0"
            temp_X = komoran.morphs(sen)
            X.append(temp_X)
        else:
            temp_X = komoran.morphs(sen)
            X.append(temp_X)
    except:
        sen = "0"
        temp_X = komoran.morphs(sen)
        X.append(temp_X)
    #temp_X = [word for word in temp_X if not word in stopwords]
    #X.append(temp_X)
    #typeError => X.append(preprocess_text(sen))

y = tweets['sentiment']

#sentiment를 긍정은 1, 부정은 0으로 수정

y = np.array(tweets['sentiment'])

drop_data = [index for index, sentence in enumerate(X) if (len(sentence) <1 or sentence == ["0"])]
X = np.delete(X, drop_data, axis=0)
y = np.delete(y, drop_data, axis = 0)

X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.20, random_state=42)

#Preparing the Embedding Layer
tokenizer = Tokenizer(num_words=10000)
tokenizer.fit_on_texts(X_train)

X_train = tokenizer.texts_to_sequences(X_train)
X_test = tokenizer.texts_to_sequences(X_test)

# Adding 1 because of reserved 0 index
vocab_size = len(tokenizer.word_index) + 1


X_train = pad_sequences(X_train, padding='post', maxlen=maxlen)
X_test = pad_sequences(X_test, padding='post', maxlen=maxlen)


new_model = keras.models.load_model('C:/Users/북미가자/Desktop/Navernews_sj/SSK_code/{}{}_1024_20_model_{}_dropnull.h5'.format(mode, maxlen, kor), compile=False)
new_model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['acc'])
new_model.summary()
loss, acc = new_model.evaluate(X_test, y_test, verbose=1)
print("복원된 모델의 정확도: {:5.2f}%".format(100*acc))

#Making Predictions on Single Instance
file_cols = ['source','date', 'text', 'level', 'link']
file = pd.read_csv("C:/Users/북미가자/Desktop/Navernews_sj/SSK_code/우울경향_test.txt", encoding = 'utf-8', header = None, names = file_cols, sep= '\t')
#flat_list = []

instance = []
sentences = list(file['text'])
for sen in sentences:
    sen = str(sen)
    instance.append(preprocess_text(sen))
tokenizer = Tokenizer(num_words=10000)
tokenizer.fit_on_texts(instance)
instance = tokenizer.texts_to_sequences(instance)

vocab_size = len(tokenizer.word_index) + 1

instance= pad_sequences(instance, padding='post', maxlen=maxlen)
results = new_model.predict(instance)
classes = new_model.predict_classes(instance)

with open('C:/Users/북미가자/Desktop/Navernews_sj/SSK_code/SSK감성결과_{}_{}_{}_{}.csv'.format(mode, maxlen, embed, kor), 'w', encoding='utf-8', newline = '') as f:
    for i in range(len(file)):
        f.write('{}\t{}\t{}\t{}\t{}\t{}\t{}\t{}\n'.format(i, file['source'][i], file['date'][i], file['text'][i], file['level'][i], file['link'][i], results[i], classes[i]))

'''
#f_cols = ['date', 'time', 'user', 'text', 'result', 'class']
f = open('./감성결과test2_{}_{}_{}_{}.csv'.format(mode, maxlen, embed, kor), 'w', encoding = 'utf-8')
csv_writer = csv.writer(f)
#csv_writer.writerow(['date', 'time', 'user', 'text', 'result', 'class'])


result_list = []
class_list = []
for i in range(len(file)):
    instance = file['text'][i]
    instance = str(instance)
    instance = tokenizer.texts_to_sequences(instance)
    flat_list = []
    for sublist in instance:
        for item in sublist:
            flat_list.append(item)

    flat_list = [flat_list]
    flat_list = np.asarray(flat_list)
    instance = pad_sequences(flat_list, padding='post', maxlen=maxlen)

    results = new_model.predict(instance)
    results_class = new_model.predict_classes(instance)
    result_list.append(results)
    class_list.append(results_class)
    print(i, str(results), str(results_class))
    #f.write('{}\t{}\t{}\t{}\t{}\t{},{},{}\n'.format(i,file['source'][i], file['date'][i], file['text'][i], file['level'][i], file['link'][i],str(results), str(results_class)))
    csv_writer.writerow([file['source'][i], file['date'][i],file['text'][i], file['level'][i], file['link'][i], str(results), str(results_class)])
    #f.write('{},{},{},{},{},{}\n'.format(file['date'][i], file['time'][i], file['user'][i], file['text'][i], str(results), str(results_class)))

'''
