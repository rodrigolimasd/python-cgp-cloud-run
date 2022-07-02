class Task(db.Model):
    __tablename__ = "tasks"
    id = db.Column(db.Integer, primary_key=True)
    title = db.Column(db.String(20))
    desc = db.Column(db.String(100))

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

