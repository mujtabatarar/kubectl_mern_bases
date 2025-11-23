import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

// Use relative path for Kubernetes (nginx proxy) or full URL for local dev
const API_URL = process.env.REACT_APP_API_URL || '';

function App() {
  const [users, setUsers] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [formData, setFormData] = useState({ name: '', email: '' });

  useEffect(() => {
    fetchUsers();
  }, []);

  const fetchUsers = async () => {
    try {
      setLoading(true);
      const url = API_URL ? `${API_URL}/api/users` : '/api/users';
      const response = await axios.get(url);
      setUsers(response.data);
      setError(null);
    } catch (err) {
      setError('Failed to fetch users. Make sure the backend is running.');
      console.error('Error fetching users:', err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      const url = API_URL ? `${API_URL}/api/users` : '/api/users';
      await axios.post(url, formData);
      setFormData({ name: '', email: '' });
      fetchUsers();
    } catch (err) {
      setError('Failed to create user. ' + (err.response?.data?.error || err.message));
      console.error('Error creating user:', err);
    }
  };

  const handleChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value
    });
  };

  return (
    <div className="App">
      <div className="container">
        <header>
          <h1>Simple React + Node.js + MySQL App</h1>
          <p>Users from MySQL Database</p>
        </header>

        <div className="content">
          <div className="form-section">
            <h2>Add New User</h2>
            <form onSubmit={handleSubmit}>
              <input
                type="text"
                name="name"
                placeholder="Name"
                value={formData.name}
                onChange={handleChange}
                required
              />
              <input
                type="email"
                name="email"
                placeholder="Email"
                value={formData.email}
                onChange={handleChange}
                required
              />
              <button type="submit">Add User</button>
            </form>
          </div>

          <div className="users-section">
            <h2>Users List</h2>
            {loading && <p className="loading">Loading users...</p>}
            {error && <p className="error">{error}</p>}
            {!loading && !error && users.length === 0 && (
              <p className="empty">No users found</p>
            )}
            {!loading && !error && users.length > 0 && (
              <div className="users-list">
                {users.map((user) => (
                  <div key={user.id} className="user-card">
                    <div className="user-info">
                      <h3>{user.name}</h3>
                      <p>{user.email}</p>
                    </div>
                    <div className="user-meta">
                      <span>ID: {user.id}</span>
                      <span>
                        {new Date(user.created_at).toLocaleDateString()}
                      </span>
                    </div>
                  </div>
                ))}
              </div>
            )}
            {!loading && (
              <button onClick={fetchUsers} className="refresh-btn">
                Refresh
              </button>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

export default App;

