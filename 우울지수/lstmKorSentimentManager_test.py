import konlpy
import pandas as pd
import numpy as np
import re
import nltk
from nltk.corpus import stopwords

from numpy import array
from keras.preprocessing.text import one_hot
from keras.preprocessing.sequence import pad_sequences
from keras.models import Sequential
from keras.layers.core import Activation, Dropout, Dense
from keras.layers import Flatten, Conv1D, LSTM
from keras.layers import GlobalMaxPooling1D
from keras.layers.embeddings import Embedding
from sklearn.model_selection import train_test_split
from keras.preprocessing.text import Tokenizer

from konlpy.tag import Okt, Kkma, Komoran

import seaborn as sns
from numpy import array
from numpy import asarray
from numpy import zeros

import matplotlib.pyplot as plt

#Importing and Analyzing the Dataset
cols = ['id', 'text', 'sentiment']
tweets = pd.read_csv("ratings.txt", encoding = 'utf-8', header = None, names = cols, sep = "\t")
#tweets = pd.read_csv('C:/Users/북미가자/Desktop/preprocess_HIO/preprocessed/전처리2_sentiment140.csv', encoding = 'utf-8', header = None, names = cols)
print(tweets.isnull().values.any())
tweets = tweets.dropna(how= "any")
print(str(tweets.shape))
print(str(tweets.head()))
print(str(tweets['text'][3]))
#sns.countplot(x = 'sentiment', data = tweets)
print(tweets.groupby('sentiment').size())

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

#stopwords = ['의','가','이','은','들','는','좀','잘','걍','과','도','를','으로','자','에','와','한','하다']
#okt = Okt()
#kkma = Kkma(max_heap_size= 1024 * 6)
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

maxlen = 30
batch_size = 1024
epoch = 20
nnmodel = "lstm"

X_train = pad_sequences(X_train, padding='post', maxlen=maxlen)
X_test = pad_sequences(X_test, padding='post', maxlen=maxlen)

#create our feature matrix
embeddings_dictionary = dict()
glove_file = open('./embeddings/word-embeddings/glove/glove.txt', encoding="utf8")

for line in glove_file:
    records = line.split()
    word = records[0]
    vector_dimensions = asarray(records[1:], dtype='float32')
    embeddings_dictionary [word] = vector_dimensions
glove_file.close()

embedding_matrix = zeros((vocab_size, 100))
for word, index in tokenizer.word_index.items():
    embedding_vector = embeddings_dictionary.get(word)
    if embedding_vector is not None:
        embedding_matrix[index] = embedding_vector

def train(mode):
    if (mode is 'simple'):
        #Text Classification with Simple Neural Network
        model = Sequential()
        embedding_layer = Embedding(vocab_size, 100, weights=[embedding_matrix], input_length=maxlen , trainable=False)
        model.add(embedding_layer)

        model.add(Flatten())
        model.add(Dense(1, activation='sigmoid'))

    elif (mode is 'cnn'):
        #Text Classification with a Convolutional Neural Network
        model = Sequential()

        embedding_layer = Embedding(vocab_size, 100, weights=[embedding_matrix], input_length=maxlen, trainable=False)
        model.add(embedding_layer)

        model.add(Conv1D(128, 5, activation='relu'))
        model.add(GlobalMaxPooling1D())
        model.add(Dense(1, activation='sigmoid'))

    elif (mode is 'lstm'):
        #Text Classification with Recurrent Neural Network (LSTM)
        model = Sequential()
        embedding_layer = Embedding(vocab_size, 100, weights=[embedding_matrix], input_length=maxlen, trainable=False)
        model.add(embedding_layer)
        model.add(LSTM(128))
        model.add(Dense(1, activation='sigmoid'))
    else:
        print('no matched deep learning algorithm')

    return model

model = train(nnmodel)
model.compile(optimizer='adam', loss='binary_crossentropy', metrics=['acc'])

print(model.summary())

#train our model
history = model.fit(X_train, y_train, batch_size=batch_size, epochs=epoch, verbose=2, validation_split=0.2)

model.save(nnmodel + "{}_{}_{}_model_Komoran_dropnull.h5".format(maxlen, batch_size, epoch))
#evaluate the performance of the mode
score = model.evaluate(X_test, y_test, verbose=2)

print("Test Score:", score[0])
print("Test Accuracy:", score[1])

print(history.history['loss'])
print(history.history['acc'])
print(history.history['val_loss'])
print(history.history['val_acc'])

##Plot##
plt.plot(history.history['acc'])
plt.plot(history.history['val_acc'])

plt.title('model accuracy')
plt.ylabel('accuracy')
plt.xlabel('epoch')
plt.legend(['train','test'], loc='upper left')

plt.grid()
plt.savefig(nnmodel + "{}_{}_{}_acc_Komoran_dropnull.pdf".format(maxlen, batch_size, epoch), bbox_inches = 'tight')
plt.show()

plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])

plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train','test'], loc='upper left')
plt.grid()
plt.savefig(nnmodel + "{}_{}_{}_loss_Komoran_dropnull.pdf".format(maxlen, batch_size, epoch), bbox_inches = 'tight')
plt.show()


#Making Predictions on Single Instance
instance = X[57]
print(instance)

instance = tokenizer.texts_to_sequences(instance)

flat_list = []
for sublist in instance:
    for item in sublist:
        flat_list.append(item)

flat_list = [flat_list]

instance = pad_sequences(flat_list, padding='post', maxlen=maxlen)

results = model.predict(instance)

print("predicted: " + str(results))
