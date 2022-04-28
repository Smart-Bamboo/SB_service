import socket

import uvicorn
from fastapi import FastAPI, Form
from fastapi.middleware.cors import CORSMiddleware

host = '127.0.0.1'
port = 11000

app = FastAPI()

origins = [
    "http://localhost:8069",
    "http://dev.odoo-smartbamboo.mx",
    "https://odoo-smartbamboo.mx",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


def client_program(message):
    client_socket = socket.socket()
    client_socket.connect((host, port))
    client_socket.send(message.encode('utf-8'))
    data = client_socket.recv(1024).decode('utf-8')
    client_socket.close()
    return data


def trn_to_dict(trn):
    dictionary = dict()
    try:
        resp = trn[:-1]
        resp = resp.replace('|Respuesta=', '')
        for param in resp.replace('|', '&').split('&'):
            params = param.split('=')
            dictionary[params[0]] = params[1]
    except:
        return trn
    return dictionary


@app.post("/")
def bridge(trn: str = Form(...)):
    data = trn
    trama = str(len(data) + 5).zfill(4) + '|' + data
    print(trama)
    try:
        socket_resp = client_program(trama)
        response = trn_to_dict(socket_resp)
    except Exception as e:
        response = {'error': str(e)}
    return response


if __name__ == "__main__":
    uvicorn.run("sb_api_service:app", host="127.0.0.1", port=5000, log_level="info")
