from flask import Flask, request, jsonify
from flask_cors import CORS
from joblib import load

clf = load('model.joblib') 

app = Flask(__name__)
CORS(app)

@app.route('/', methods=['GET'])
def Home():
    return "<p> Hello :) !!</p>"

        
@app.route('/Predict', methods=['POST'])
def Predict():
    global predicted
    if request.method == 'POST':
        requested_data = request.get_json()
        data =([requested_data["value"]])
        print(data)
        predicted = clf.predict(data)
        return str(predicted.tolist()[0]) , 200
    
@app.route('/getPredict', methods=['GET'])
def getPredict():
    if request.method == 'GET':
        return jsonify(value = (predicted.tolist()[0])) , 200

if __name__ == "__main__":
    app.run(host="192.168.1.2",port=5000, debug=True)