import React from "react";

export default function CouponTable({ data }) {
  return (
    <div className="table-wrapper">
      <h3>Coupon Usage Details</h3>

      <table>
        <thead>
          <tr>
            <th>Employee Name</th>
            <th>Employee ID</th>
            <th>Date</th>
            <th>Status</th>
          </tr>
        </thead>

        <tbody>
          {data.length === 0 ? (
            <tr>
              <td colSpan="4" style={{ textAlign: "center" }}>
                Click a card above to view records
              </td>
            </tr>
          ) : (
            data.map((row, i) => (
              <tr key={i}>
                <td>{row.name}</td>
                <td>{row.empId}</td>
                <td>{row.date}</td>
                <td>
                  <span className={row.status === "Used" ? "used" : "unused"}>
                    {row.status}
                  </span>
                </td>
              </tr>
            ))
          )}
        </tbody>
      </table>
    </div>
  );
}
