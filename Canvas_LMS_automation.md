# Canvas LMS tips

## Browser automation as an alternative to using Speedgrader

While Speedgrader may be helpful in certain scenarios, sometimes it can be not so speedy. There can be a lot of time spent on tasks such as loading the page, scrolling to a specific question, clicking buttons, typing in text, etc. which can add up to huge chucks of time if you do that for hundreds of students.

The goal for this post is to show how those menial tasks can be automated so that you do not have to spend more time than needed to grade an assignemnt.

### Doing the actual grading in a spreadsheet

To better streamline the grading process I find it beneficial to see all the answers right next to each other. You can grade via a spreadsheet by exporting the "Student Analysis" breakdown of the quiz questions. This is done by doing the following:
1) Click on the Quizzes tab
2) Click on particular quiz you are interested in grading
3) Click on "Quiz Statistics"
4) Click on "Student Analysis"
5) The report should be automatically downloaded as a csv file

Once you have the file you can import it to Excel, Libre Office Calc, or Google Sheets. You can make a separate sheet within the spreadsheet which has a subset f needed columns includeing the student id, each free response question to grade, and a score column for each free response question.

Then you can go down the spreadsheet and grade the responses by altering the score column to reflect the points attributed to each answer. When the grading is done, you can create another column that formats the responses to a python list syntax. Each row will have the student id, and scores for each answer. Something like: ```[297555,3],``` (which can be made by using the CONCAT function like: ```=CONCAT("[",A1,",",B1,"],",")```. 

### Submitting the list of grades via web browser automation in python

Once the correctly formated column is made, it can be copied and pasted into the script below as the variable: ```grade_list```. Just make sure the comma for the last item is removed.

The script can be edited to run all at once, but because it requires logging in and that may be more complicated with DUO and authentication requirements, I have made the script so that you start up a python instance in the terminal and then just copy and paste the script in chunks. Part1 creates an automated browser instance where you can manually then enter your credentials to Canvas. Once logged in you can copy and paste Part2 in order to enter all the scores based on the grade_dict that was pasted in.

##### Requirements

For this to run you will need to have selenium installed as a python package as well as a webdriver that is specific for whaterver browser you plan to use. For Chrome you can download the driver at: https://chromedriver.chromium.org/downloads

Also for each quiz you will have to obtain different values for the 

##### The webdriver script
```
# Part1
import time
from selenium import webdriver
browser = webdriver.Chrome('/home/tslaird/chromedriver_linux64/chromedriver') # local path to webdriver
course_id = 742396 # the id for the course you are grading for
browser.get('https://canvas.ucdavis.edu/courses/'+str(course_id))

already_graded = []
grading_errors=[]

grade_list=[
[230234,0.9,1],
[235418,1,1],
[232317,1,1],
[240559,1,1],
[225325,1,1],
[234447,1,1],
[304385,1,0.66],
[295253,0.9,1],
[256453,0.9,1],
[302397,1,1],
[234279,0.9,1],
[255202,1,1],
[227255,1,1],
[262289,0.5,1],
[302205,1,1],
[267223,1,1],
[301268,0.2,0.66],
[303270,0.56,0.9],
[235288,1,1],
[256231,0.1,1],
[230295,0.9,1],
[112266,1,1],
[260263,1,1],
[236225,0.9,1],
[294281,1,1],
[252564,0.9,1],
[302179,1,1],
[262687,1,1],
[292449,1,1],
[292517,0.9,1],
[302287,0.9,0.66],
[292816,1,1],
[222512,1,1],
[222663,0.66,0.66],
[292476,1,1],
[232136,0.66,1],
[225857,1,1],
[229777,1,1]
]

# the following is a loop for iterating over the list of lists and submitting specified grades for each question.
# The script can be modified to include more or less questions or even add comments to additional fields if necessary.
for l in grade_list:
    if l[0] not in already_graded:
        print('Entering grade for student: '+str(l[0]))
    # the url and assignment_id variable below will need to be changed depending on the course and quiz id     
    desired_url='https://canvas.ucdavis.edu/courses/742386/gradebook/speed_grader?assignment_id=1019282&student_id='+str(l[0])
        browser.get(desired_url)
        # lag time to allow for loading the page
        # there are better ways to wait until elements are visible in selenium so this can be modified if desired
        time.sleep(5)
        actual_url=browser.current_url
        assert actual_url==desired_url, f"not on correct url"
        frame = browser.find_element_by_xpath('//*[@id="speedgrader_iframe"]')
        browser.switch_to.frame(frame)
        # this will change depending on the question to be graded
        # you can find this info by using the inspect tool in Chrome
        # via the Speedgrader interface
        # it only needs to be done once though
        #question 1
        question1_id = "question_score_2211248_visible"
        score_val = browser.find_element_by_id(question1_id)
        score_val.clear()
        browser.find_element_by_id(question1_id).send_keys(str(l[1])) # send the score to the entry box
        time.sleep(4)
        #question 2
        question2_id = "question_score_2211250_visible"
        score_val = browser.find_element_by_id(question2_id)
        score_val.clear()
        browser.find_element_by_id(question2_id).send_keys(str(l[2])) # send the score to the entry box
        time.sleep(4)
        #update score
        browser.find_element_by_css_selector("#update_scores > div.update_scores > div > button").click()
        time.sleep(4)
        #gets the total score
        total=browser.find_element_by_id('after_fudge_points_total')
        print("Final grade for "+ str(l[0])+": "+ total.text)
        already_graded.append(l[0])
        total=browser.find_element_by_id('after_fudge_points_total')
        print("Final grade for "+ str(l[0])+": "+ total.text)
        already_graded.append(l[0])
            #the following writes the already graded ids to a file
        with open('quiz_graded.txt','a') as gradefile:
            gradefile.write(str(l[0])+'\n')
    else:
        print('Already graded student: '+str(l[0]) )

```

For the most part, this script should run smoothly and allow you to back away from the computer while the webdriver does all the clicking, entering, and scrolling. If the webdriver crashes or stalls for some reason you can start the process again with Part1 (logging on) and subsequently Part2 (submitting grades). The students that were already graded will be skipped since those ids are stored in the "already_graded" list.

## Alternatives to browser automation

One alternative is to use the Canvas LMI API (https://canvas.instructure.com/doc/api/) to automate grading. I'm sure there is a way to utilize this API for grading individual questions, although the documentation is not very helpful in that sense. I have tried chatting with Canvas support about such a task and they first question my motives as to why I don't want to use the Speedgrader, and then simply direct me to this document (https://canvas.instructure.com/doc/api/quiz_submissions.html). However, I have tried different url request combinations and can not seem to figure out how to do what I want. Perhaps this is a problem someone else can solve. The live API interface they have (https://canvas.instructure.com/doc/api/live#!) seems promising for troubleshooting this task. However, based on certain forum posts it seems that others have run into this problem as well (see: https://community.canvaslms.com/t5/Canvas-Developers-Group/Quiz-Grading-via-API/td-p/115685) and similarly got the runaround from the development team. This quote from user u6032171 on 11-09-2020 definately resonates with my experience, 
> "Instead of documenting the fact that the API doesn't work on the API page, Instructure forces me to go all around the world looking for this thread, which clarifies that not only can Instructure not make a functional website, they can't even make a functional REST API.  This level of incompetence is truly astounding"

Another potential alternative is to use a headless browser to save more time in terms of actual page loading via Selenium and Chrome.


#### Python requests sandbox code

```
url = 'https://canvas.instructure.com/api/v1/courses/34380000000742386/assignments'
header = {'Authorization' : 'Bearer token_goes_here'}
r = requests.get(url,headers = headers)
print(r.status_code)
print(r.text)
print(r.json)
```
