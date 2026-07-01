f : Type -> Type -> Type
f a b = a -> b

g : f Type Type
g a = a -> a
