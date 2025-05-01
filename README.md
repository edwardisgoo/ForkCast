<<<<<<< HEAD
# ForkCast
=======
# Lab 07 Meals app with ProxyProvider

During this lab session, you will need to **implement a ChangeNotifierProxyProvider2** globally and listen to a **FilteredMealsNotifier**, if implemented correctly, the **MealsPage** can acquire the **filteredmeals** list from the provider directly, instead of re-computeing filteredMeals in every calling of it's build function.  

The lab project (courses > software-studio > 2025-spring > lab-flutter-basics-dart-meals-app) provides the meals app before implementing the proxyProvider.


# Description
In the current state of the meals app, in the **Mealspage** widget, the filteredMeals are re-computed in every calling of build, this is obviously inefficient because not every update of the MealsPage contain changes in the filteredMeals list, so re-computing it everytime creates system overhead.  

With the knowledge of **flutter providers** you've learnt from the lecture, it's easy for us to consider using providers to rewrite this so that **filteredMeals** is recomputed only when filters change, and this is exactly what you're required to do.

In order to calculate the filtered meals, you need to acquire the total meal list and the currently enabled filters, ~~Unfortunately~~ but these information are alreadly stored in a **changeNotifier** type class and provided by providers, so we'll have to use the **proxyproviders** mentioned in the lecture.


# Code explaination
![alt text](gitlab_images/img1.png)

*In MealsPage,  we want this part to be provided by a provider, so it becomes something like the code below.*


![alt text](gitlab_images/img2.png)


# Grading

Because this lab has no visible changes in the app itself, so we'll went through your code to see if there's correct implementions.


1. App compiles and runs with all of it's original functions  **(20%)**  
  

2. Let the **filteredMeals** in **MealsPage** use **FilteredMealsNotifier** provided by ChangeNotifierProxyProvider2 globally **(80%)**



# Hints
- Go through the thought process of creating and using a provider, then examin where to implement each parts of the code 

- Refer to other existing providers in this project and see how they do the implementations

- there's a empty dart file **filtered_meals_notifier.dart** under /state folder, implement the new notifier and the calculations there.

- You’ll use Dart’s cascade operator “..” when defining the “update” properity of ChangeNotifierProxyProvider2



# Deadline
Submit your work before 2025/04/24 (Thur.) 17:20:00.

The score you have done will be 100%.

Submit your work before 2025/04/24 (Thur.) 23:59:59.

The score of other part you have done after 17:20:00 will be 60%.

# Resources

A few introductory tutorials crafted to assist you in completing today's lab.


- [ProxyProvider](https://pub.dev/packages/provider#proxyprovider)
- [ChangeNotifierProxyProvider2](https://pub.dev/documentation/provider/latest/provider/ChangeNotifierProxyProvider2-class.html)


>>>>>>> cddb8be (Lab7 as template)
