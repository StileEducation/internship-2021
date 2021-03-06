export class Teacher {
  constructor(ID, name, DOB, ambition) {
    this._ID = ID;
    this._name = name;
    this._DOB = DOB;
    this._ambition = this.validateAmbition(ambition);
    this._faveStudent = null;
    this._hatedStudent = null;
    this._subjects = {};
  }

  assignGrade(student, subject, grade) {
    this._subjects[subject]._students[student].addGrade(subject, grade);
    // we had to make them know about the classes they were in, we couldn't think of any other way to do this
  }

  doYourJob(subjectID) {
    let currentSubject = this._subjects[subjectID];
    for (let studentID in currentSubject._students) {
      // console.log(studentID);
      // console.log(
      //   currentSubject._students[studentID]._grades[subjectID] === undefined
      // );
      /*       let i = 0;
      while (i >= 0) {
        i++;
        console.log(i);
      } */
      while (
        currentSubject._students[studentID]._grades[subjectID] === undefined
      ) {
        console.log(studentID);
        let grade;
        try {
          grade = Math.floor(Math.random() * 101); //randomly generated percentage
          this.assignGrade(studentID, subjectID, grade);
          console.log("Success!");
        } catch (err) {
          console.log(studentID, grade);
          console.log(err);
        }
      }
      // while there is not a grade assigned, do this
      // console.log(
      //   currentSubject._students[studentID]._grades[subjectID] === undefined
      // );
    }
  }

  validateAmbition(ambition) {
    const validAmbitions = [
      "Create a student army",
      "Kill the principal and take their job",
      "Doing the bare minimum until they retire",
    ];

    if (validAmbitions.includes(ambition)) {
      return ambition;
    } else {
      throw new Error("Invalid ambition.");
    }
  }
}
