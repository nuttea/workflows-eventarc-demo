import random, json, math, functions_framework
from flask import jsonify, abort

@functions_framework.http
def floor(request):
  if request.method == 'POST':
    request_json = request.get_json()
    output = math.floor(float(request_json['input']))
    return jsonify(output)
  elif request.method == 'PUT':
    return abort(403)
  else:
    return abort(405)