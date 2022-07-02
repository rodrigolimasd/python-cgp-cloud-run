import os

from flask import Flask, request, jsonify, make_response
from flask_sqlalchemy import SQLAlchemy
from marshmallow import fields
from marshmallow_sqlalchemy import SQLAlchemySchema
from flask_marshmallow import Marshmallow

app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:mysqlpass@localhost:3306/pytask'
db = SQLAlchemy(app)
ma = Marshmallow(app) 

class Task(db.Model):
    __tablename__ = "task"
    id = db.Column(db.Integer, primary_key = True)
    title = db.Column(db.String(10), nullable = False)
    desc = db.Column(db.String(30), nullable = True)
    
    def create(self):
       db.session.add(self)
       db.session.commit()
       return self

    def __init__(self, title, desc):
        self.title = title
        self.desc = desc
    
    def __repr__(self):
       return f"{self.id}"

db.create_all()

class TaskSchema(ma.SQLAlchemySchema):
   class Meta:
       model = Task
       load_instance = True
   id = fields.Number(dump_only=True)
   title = fields.String(required=True)
   desc = fields.String(required=True)


@app.route("/")
def hello_world():
    name = os.environ.get("NAME", "CGP Cloud Run - V2")
    return "Hello {}!".format(name)

@app.route('/api/v1/task', methods=['POST'])
def create():
   data = request.get_json()
   task_schema = TaskSchema()
   task = task_schema.load(data)
   result = task_schema.dump(task.create())
   return make_response(jsonify({"task": result}), 201)

@app.route('/api/v1/task', methods=['GET'])
def index():
   get_tasks = Task.query.all()
   task_schema = TaskSchema(many=True)
   tasks = task_schema.dump(get_tasks)
   return make_response(jsonify({"tasks": tasks}))

@app.route('/api/v1/task/<id>', methods=['DELETE'])
def delete_task_by_id(id):
   get_task = Task.query.get(id)
   db.session.delete(get_task)
   db.session.commit()
   return make_response("", 204)


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))