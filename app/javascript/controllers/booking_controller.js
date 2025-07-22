import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["location", "calendar", "teacher", "timeslot"]

  connect() {
    // Optional: initialization logic
  }

  selectLocation(event) {
    this.clearSteps(["calendar", "teacher", "timeslot"]);
    const locationId = event.target.value;
    if (locationId) {
      fetch(`/lessons/available_days?location_id=${locationId}`, { headers: { "Accept": "text/vnd.turbo-stream.html" } })
        .then(res => res.text())
        .then(html => { this.calendarTarget.innerHTML = html; });
    }
  }

  selectDay(event) {
    this.clearSteps(["teacher", "timeslot"]);
    const date = event.target.dataset.date;
    const locationId = event.target.dataset.locationId;
    fetch(`/lessons/available_teachers?date=${date}&location_id=${locationId}`, { headers: { "Accept": "text/vnd.turbo-stream.html" } })
      .then(res => res.text())
      .then(html => { this.teacherTarget.innerHTML = html; });
  }

  selectTeacher(event) {
    this.clearSteps(["timeslot"]);
    const teacherId = event.target.dataset.teacherId;
    const date = event.target.dataset.date;
    const locationId = event.target.dataset.locationId;
    fetch(`/lessons/available_timeslots?teacher_id=${teacherId}&date=${date}&location_id=${locationId}`, { headers: { "Accept": "text/vnd.turbo-stream.html" } })
      .then(res => res.text())
      .then(html => { this.timeslotTarget.innerHTML = html; });
  }

  bookTimeslot(event) {
    const teacherId = event.target.dataset.teacherId;
    const locationId = event.target.dataset.locationId;
    const startTime = event.target.dataset.startTime;
    fetch("/lessons", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        "Accept": "text/vnd.turbo-stream.html"
      },
      body: JSON.stringify({ teacher_id: teacherId, location_id: locationId, start_time: startTime })
    })
    .then(res => res.text())
    .then(html => {
      if (html.includes("Lesson booked!")) {
        Turbo.visit("/lessons");
      } else {
        this.timeslotTarget.innerHTML = html;
      }
    });
  }

  clearSteps(targets) {
    targets.forEach(t => this[`${t}Target`].innerHTML = "");
  }
}