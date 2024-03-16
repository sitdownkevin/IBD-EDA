# Object (Class) -> Instance

class Animal:
    def __init__(self, name, age) -> None:
        self.name = name
        self.age = age
        
    
    def walk(self):
        pass
        
        
        
class Dog(Animal):
    def __init__(self, name, age) -> None:
        super().__init__(name, age)
        
        
    def bark(self):
        pass   


class People(Animal):
    def __init__(self, name, age) -> None:
        super().__init__(name, age)
        
        
    def eat(self):
        pass


dog = Dog('wangzai', 2)
dog.bark()
dog.walk()


xk = People('xk', 20)
xk.walk()
# njy = People('njy', 20)





