import { School } from "./School";

let stileSchool;

beforeEach(() => {
  //create successful variable
  stileSchool = new School("Stile School", "Melbourne", "Seedling");
});

describe("Start of Term", () => {
  test("Creating a school", () => {
    expect(stileSchool).toEqual({
      _name: "Stile School",
      _suburb: "Melbourne",
      _mascot: "Seedling",
      _teachers: {},
      _subjects: {},
      _students: {},
    });
  });

  test("Hiring a teacher", () => {
    let DOB = new Date(1974, 6, 8);
    let testID = stileSchool.hireTeacher(
      "Ms Jenkins",
      DOB,
      "Kill the principal and take their job"
    );
    expect(stileSchool.teachers).toEqual({
      [testID]: {
        _ID: testID,
        _name: "Ms Jenkins",
        _DOB: DOB,
        _faveStudent: null,
        _hatedStudent: null,
        _ambition: "Kill the principal and take their job",
        _subjects: {},
      },
    });
  });

  test("Creating a subject", () => {
    let DOB = new Date(1974, 6, 8);
    let staffID = stileSchool.hireTeacher(
      "Ms Jenkins",
      DOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[staffID]
    );
    expect(stileSchool.subjects).toEqual({
      [subjectID]: {
        _ID: subjectID,
        _teacher: stileSchool.teachers[staffID],
        _assistantTeacher: null,
        _students: {},
        _name: "Year 10 Maths",
        _room: "10B",
        _times: ["Monday 10:00 am", "Thursday 12:30 pm"],
      },
    });
  });

  test("Enrol a student", () => {
    let DOB = new Date(2004, 6, 8);
    let testID = stileSchool.enrolStudent(
      "Polly Cracker",
      DOB,
      "Cheese and biscuits",
      "Hearts"
    );
    expect(stileSchool.students).toEqual({
      [testID]: {
        _ID: testID,
        _name: "Polly Cracker",
        _DOB: DOB,
        _faveFood: "Cheese and biscuits",
        _faveSuit: "Hearts",
        _grades: {},
      },
    });
  });

  test("Assign assistant teacher", () => {
    let DOB = new Date(1974, 6, 8);
    let primaryID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      DOB,
      "Kill the principal and take their job"
    );

    let assistantID = stileSchool.hireTeacher(
      //assistant teacher
      "Mr Smith",
      DOB,
      "Doing the bare minimum until they retire"
    );

    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[primaryID]
    );
    stileSchool.assignAssistantTeacher(subjectID, assistantID);

    expect(stileSchool._subjects[subjectID]["_assistantTeacher"]).toEqual(
      stileSchool._teachers[assistantID]
    ); //check specific property
  });

  test("Assign student to a class", () => {
    let teacherDOB = new Date(1974, 6, 8);
    let teacherID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      teacherDOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[teacherID]
    );
    let studentDOB = new Date(2004, 6, 8); //student
    let studentID = stileSchool.enrolStudent(
      "Polly Cracker",
      studentDOB,
      "Cheese and biscuits",
      "Hearts"
    );
    stileSchool.assignStudent(subjectID, studentID);
    expect(stileSchool._subjects[subjectID]._students).toEqual({
      [studentID]: stileSchool._students[studentID], //this is students obj with studentID in it, referring to the same obj as the one in the school
    });
  });
});

describe("End of term", () => {
  test("check if student can add grade", () => {
    let studentDOB = new Date(2004, 6, 8);
    let studentID = stileSchool.enrolStudent(
      "Polly Cracker",
      studentDOB,
      "Cheese and biscuits",
      "Hearts"
    );
    let teacherDOB = new Date(1974, 6, 8);
    let teacherID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      teacherDOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[teacherID]
    );
    stileSchool._students[studentID].addGrade(subjectID, 20);
    expect(stileSchool._students[studentID]._grades).toEqual({
      [subjectID]: { percent: 20, grade: "slug" },
    });
    //create a student
    //call the addGrade() method
    //check to see if the grades obj has the percentage in it
  });

  test("Teacher can assign grade", () => {
    let studentDOB = new Date(2004, 6, 8);
    let studentID = stileSchool.enrolStudent(
      "Polly Cracker",
      studentDOB,
      "Cheese and biscuits",
      "Hearts"
    );
    let teacherDOB = new Date(1974, 6, 8);
    let teacherID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      teacherDOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[teacherID]
    );
    stileSchool.assignStudent(subjectID, studentID);
    stileSchool._teachers[teacherID].assignGrade(studentID, subjectID, 75);
    expect(stileSchool._students[studentID]._grades).toEqual({
      [subjectID]: { percent: 75, grade: "chameleon" },
    });
  });

  test("Adding grades for a whole class of students", () => {
    let studentDOB = new Date(2004, 6, 8);
    let studentID = stileSchool.enrolStudent(
      "Polly Cracker",
      studentDOB,
      "Cheese and biscuits",
      "Hearts"
    );
    let studentDOB2 = new Date(2003, 7, 5);
    let studentID2 = stileSchool.enrolStudent(
      "Harriet Harrietson",
      studentDOB2,
      "Cheezels",
      "Spades"
    );
    let teacherDOB = new Date(1974, 6, 8);
    let teacherID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      teacherDOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[teacherID]
    );
    stileSchool.assignStudent(subjectID, studentID);
    stileSchool.assignStudent(subjectID, studentID2);
    stileSchool._teachers[teacherID].doYourJob(subjectID);

    expect(stileSchool._students[studentID]._grades).toHaveProperty([
      subjectID,
    ]);

    expect(stileSchool._students[studentID2]._grades).toHaveProperty([
      subjectID,
    ]);
  });

  test("it's grading time!", () => {
    let studentDOB = new Date(2004, 6, 8);
    let studentID = stileSchool.enrolStudent(
      "Polly Cracker",
      studentDOB,
      "Cheese and biscuits",
      "Hearts"
    );
    let studentDOB2 = new Date(2003, 7, 5);
    let studentID2 = stileSchool.enrolStudent(
      "Harriet Harrietson",
      studentDOB2,
      "Cheezels",
      "Spades"
    );
    let teacherDOB = new Date(1974, 6, 8);
    let teacherID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      teacherDOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[teacherID]
    );
    stileSchool.assignStudent(subjectID, studentID);
    stileSchool.assignStudent(subjectID, studentID2);
    let subjectID2 = stileSchool.createSubject(
      "Baby Maths (Yr 7)",
      "3G",
      ["Tuesday 12:00 pm", "Thursday 10:00 am"],
      stileSchool.teachers[teacherID]
    );
    stileSchool.assignStudent(subjectID2, studentID);
    stileSchool.assignStudent(subjectID2, studentID2);
    stileSchool.gradingTime();
    expect(stileSchool._students[studentID]._grades).toHaveProperty([
      subjectID,
    ]);
    expect(stileSchool._students[studentID]._grades).toHaveProperty([
      subjectID2,
    ]);

    expect(stileSchool._students[studentID2]._grades).toHaveProperty([
      subjectID,
    ]);
    expect(stileSchool._students[studentID2]._grades).toHaveProperty([
      subjectID2,
    ]);
  });

  test("invalid grades are not assigned", () => {
    let studentDOB = new Date(2004, 6, 8);
    let studentID = stileSchool.enrolStudent(
      "Anne of Green Gables", // not allowed a narwhal grade
      studentDOB,
      "Cheese and biscuits",
      "Hearts"
    );
    let studentDOB2 = new Date(2003, 7, 5);
    let studentID2 = stileSchool.enrolStudent(
      "Mat", // only allowed sloth or narwhal
      studentDOB2,
      "Cheezels",
      "Spades"
    );
    let teacherDOB = new Date(1974, 6, 8);
    let teacherID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      teacherDOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[teacherID]
    );
    stileSchool.assignStudent(subjectID, studentID);
    stileSchool.assignStudent(subjectID, studentID2);

    expect(() => {
      stileSchool._students[studentID].addGrade(subjectID, 98);
    }).toThrow(Error); // should throw an error
    expect(() => {
      stileSchool._students[studentID2].addGrade(subjectID, 45);
    }).toThrow(Error); // should also throw an error
  });

  test("all students will recieve a grade, even if errors are thrown", () => {
    let studentDOB = new Date(2004, 6, 8);
    let studentID = stileSchool.enrolStudent(
      "Anne of Green Gables", // not allowed a narwhal grade
      studentDOB,
      "Cheese and biscuits",
      "Hearts"
    );
    let studentDOB2 = new Date(2003, 7, 5);
    let studentID2 = stileSchool.enrolStudent(
      "Mat", // only allowed sloth or narwhal
      studentDOB2,
      "Cheezels",
      "Spades"
    );
    let teacherDOB = new Date(1974, 6, 8);
    let teacherID = stileSchool.hireTeacher(
      //primary teacher
      "Ms Jenkins",
      teacherDOB,
      "Kill the principal and take their job"
    );
    let subjectID = stileSchool.createSubject(
      "Year 10 Maths",
      "10B",
      ["Monday 10:00 am", "Thursday 12:30 pm"],
      stileSchool.teachers[teacherID]
    );
    stileSchool.assignStudent(subjectID, studentID);
    stileSchool.assignStudent(subjectID, studentID2);

    console.log("hello");
    stileSchool.gradingTime();

    // expect them both to have grades
    expect(stileSchool._students[studentID]._grades).toHaveProperty([
      subjectID,
    ]);

    expect(stileSchool._students[studentID2]._grades).toHaveProperty([
      subjectID,
    ]);
  });
});
