import React, { useEffect, useState, useMemo } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import api from '../services/api';
import PageHeader from '../components/PageHeader';
import { CircularProgress } from '@mui/material';

// Icons
import ArrowBackIcon from '@mui/icons-material/ArrowBack';
import LocationOnIcon from '@mui/icons-material/LocationOn';
import SearchIcon from '@mui/icons-material/Search';
import BadgeIcon from '@mui/icons-material/Badge';
import RestaurantMenuIcon from '@mui/icons-material/RestaurantMenu';

export default function CanteenInspectPage({ user }) {
  const { id } = useParams();
  const navigate = useNavigate();
  
  const [loading, setLoading] = useState(true);
  const [data, setData] = useState(null);
  const [searchQuery, setSearchQuery] = useState('');
  const [activeTab, setActiveTab] = useState('personnel'); // 'personnel', 'menus'

  useEffect(() => {
    const fetchCanteenDetails = async () => {
      try {
        const res = await api.get(`/inspect/canteen/${id}`);
        setData(res.data);
      } catch (err) {
        console.error("Error fetching canteen details:", err);
        alert("Failed to load canteen details. Please check your access or try again later.");
      } finally {
        setLoading(false);
      }
    };
    fetchCanteenDetails();
  }, [id]);

  const filteredPersonnel = useMemo(() => {
    if (!data?.personnel) return [];
    if (!searchQuery) return data.personnel;
    const q = searchQuery.toLowerCase();
    return data.personnel.filter(p => 
      p.name?.toLowerCase().includes(q) || 
      p.id?.toLowerCase().includes(q) ||
      p.department?.toLowerCase().includes(q) ||
      p.role?.toLowerCase().includes(q)
    );
  }, [data, searchQuery]);

  if (loading) {
    return (
      <div className="fade-in" style={{ padding: '40px', display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center', minHeight: '50vh' }}>
        <CircularProgress size={32} style={{ color: "var(--ink)", marginBottom: 16 }} />
        <div style={{ color: 'var(--ink-muted)' }}>Inspecting Canteen Module #{id}...</div>
      </div>
    );
  }

  if (!data) return null;

  const { canteen, project, menus } = data;

  return (
    <div className="fade-in dashboard-content-area" style={{ fontFamily: '"Geist", "Inter", sans-serif' }}>
      <button 
        onClick={() => navigate(-1)}
        style={{ 
          display: 'flex', alignItems: 'center', gap: '6px', 
          background: 'transparent', border: 'none', cursor: 'pointer',
          color: 'var(--ink-muted)', fontSize: '13px', fontWeight: 500,
          marginBottom: '16px', padding: 0
        }}
      >
        <ArrowBackIcon style={{ fontSize: 16 }} />
        Back to Estate
      </button>

      <PageHeader
        eyebrow={`Canteen Module #${canteen.id}`}
        title={canteen.name}
        italicTail="details"
        description={`Associated with ${canteen.project_name || 'a project'} located in ${canteen.project_location || canteen.location}. Active from ${canteen.open_time?.substring(0,5)} to ${canteen.close_time?.substring(0,5)}.`}
      />

      <div style={{ display: 'flex', gap: '32px', borderBottom: '1px solid var(--hairline)', marginBottom: '32px' }}>
        <button
          onClick={() => setActiveTab('personnel')}
          style={{
            background: 'transparent', border: 'none', cursor: 'pointer', padding: '0 0 12px 0',
            color: activeTab === 'personnel' ? 'var(--ink)' : 'var(--ink-muted)',
            fontWeight: activeTab === 'personnel' ? 600 : 500,
            borderBottom: activeTab === 'personnel' ? '2px solid var(--ink)' : '2px solid transparent',
            display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px'
          }}
        >
          <BadgeIcon style={{ fontSize: 18 }} />
          Personnel & Directory
        </button>
        <button
          onClick={() => setActiveTab('menus')}
          style={{
            background: 'transparent', border: 'none', cursor: 'pointer', padding: '0 0 12px 0',
            color: activeTab === 'menus' ? 'var(--ink)' : 'var(--ink-muted)',
            fontWeight: activeTab === 'menus' ? 600 : 500,
            borderBottom: activeTab === 'menus' ? '2px solid var(--ink)' : '2px solid transparent',
            display: 'flex', alignItems: 'center', gap: '8px', fontSize: '14px'
          }}
        >
          <RestaurantMenuIcon style={{ fontSize: 18 }} />
          Active Menus
        </button>
      </div>

      {activeTab === 'personnel' && (
        <div>
          <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: '24px' }}>
            <div style={{ position: 'relative', width: '100%', maxWidth: '400px' }}>
              <SearchIcon style={{ position: 'absolute', left: '12px', top: '50%', transform: 'translateY(-50%)', color: 'var(--ink-muted)', fontSize: 18 }} />
              <input
                className="input-atelier"
                placeholder="Search by name, ID, role or department..."
                value={searchQuery}
                onChange={(e) => setSearchQuery(e.target.value)}
                style={{ width: '100%', paddingLeft: '40px' }}
              />
            </div>
            <div className="eyebrow">{filteredPersonnel.length} member{filteredPersonnel.length !== 1 ? 's' : ''} found</div>
          </div>

          <div className="atelier" style={{ padding: 0, overflow: 'hidden' }}>
            <table style={{ width: '100%', borderCollapse: 'collapse', textAlign: 'left' }}>
              <thead>
                <tr style={{ background: 'var(--paper-2)', borderBottom: '1px solid var(--hairline)' }}>
                  <th style={{ padding: '16px 24px', fontSize: '11px', textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--ink-muted)', fontWeight: 600 }}>Employee</th>
                  <th style={{ padding: '16px 24px', fontSize: '11px', textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--ink-muted)', fontWeight: 600 }}>Role</th>
                  <th style={{ padding: '16px 24px', fontSize: '11px', textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--ink-muted)', fontWeight: 600 }}>Department</th>
                  <th style={{ padding: '16px 24px', fontSize: '11px', textTransform: 'uppercase', letterSpacing: '0.05em', color: 'var(--ink-muted)', fontWeight: 600 }}>Location</th>
                </tr>
              </thead>
              <tbody>
                {filteredPersonnel.length > 0 ? filteredPersonnel.map((person, idx) => (
                  <tr key={person.id} style={{ borderBottom: idx === filteredPersonnel.length - 1 ? 'none' : '1px solid var(--hairline)' }}>
                    <td style={{ padding: '16px 24px' }}>
                      <div style={{ fontWeight: 500, color: 'var(--ink)', fontSize: '14px' }}>{person.name}</div>
                      <div className="font-mono-tab" style={{ color: 'var(--ink-muted)', fontSize: '12px', marginTop: '4px' }}>{person.id}</div>
                    </td>
                    <td style={{ padding: '16px 24px' }}>
                      <span style={{
                        display: 'inline-block',
                        padding: '4px 8px',
                        borderRadius: '4px',
                        fontSize: '11px',
                        fontWeight: 600,
                        textTransform: 'uppercase',
                        letterSpacing: '0.05em',
                        background: person.role === 'canteen_admin' ? 'rgba(234, 88, 12, 0.1)' : 
                                    person.role === 'hr_admin' ? 'rgba(37, 99, 235, 0.1)' : 'var(--paper-2)',
                        color: person.role === 'canteen_admin' ? '#ea580c' : 
                               person.role === 'hr_admin' ? '#2563eb' : 'var(--ink-muted)'
                      }}>
                        {person.role.replace('_', ' ')}
                      </span>
                    </td>
                    <td style={{ padding: '16px 24px', fontSize: '13px', color: 'var(--ink)' }}>
                      <div>{person.department || '-'}</div>
                      <div style={{ color: 'var(--ink-muted)', fontSize: '12px', marginTop: '4px' }}>{person.designation || '-'}</div>
                    </td>
                    <td style={{ padding: '16px 24px', fontSize: '13px', color: 'var(--ink)' }}>
                      <div style={{ display: 'flex', alignItems: 'center', gap: '4px' }}>
                        {person.location && <LocationOnIcon style={{ fontSize: 14, color: 'var(--ink-muted)' }} />}
                        {person.location || '-'}
                      </div>
                    </td>
                  </tr>
                )) : (
                  <tr>
                    <td colSpan="4" style={{ padding: '32px', textAlign: 'center', color: 'var(--ink-muted)', fontSize: '13px' }}>
                      No personnel matching your search.
                    </td>
                  </tr>
                )}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {activeTab === 'menus' && (
        <div style={{ display: 'flex', flexDirection: 'column', gap: '32px' }}>
          {/* Food Menu */}
          <div className="atelier" style={{ padding: '24px' }}>
            <h3 className="font-display" style={{ fontSize: '18px', marginBottom: '16px' }}>Food Menu</h3>
            {menus.food?.length > 0 ? (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '16px' }}>
                {menus.food.map((m, i) => (
                  <div key={i} style={{ padding: '12px', border: '1px solid var(--hairline)', borderRadius: '8px', background: 'var(--paper-2)' }}>
                    <div className="eyebrow" style={{ marginBottom: '8px' }}>Day {m.day_of_week}</div>
                    <div style={{ fontSize: '13px', color: 'var(--ink)', lineHeight: 1.5 }}>
                      {typeof m.items === 'string' ? JSON.parse(m.items).join(', ') : (m.items?.join(', ') || '-')}
                    </div>
                  </div>
                ))}
              </div>
            ) : <div style={{ fontSize: '13px', color: 'var(--ink-muted)' }}>No food menu configured.</div>}
          </div>

          {/* Fruit Menu */}
          <div className="atelier" style={{ padding: '24px' }}>
            <h3 className="font-display" style={{ fontSize: '18px', marginBottom: '16px' }}>Fruit Menu</h3>
            {menus.fruit?.length > 0 ? (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '16px' }}>
                {menus.fruit.map((m, i) => (
                  <div key={i} style={{ padding: '12px', border: '1px solid var(--hairline)', borderRadius: '8px', background: 'var(--paper-2)' }}>
                    <div className="eyebrow" style={{ marginBottom: '8px' }}>Day {m.day_of_week}</div>
                    <div style={{ fontSize: '13px', color: 'var(--ink)', lineHeight: 1.5 }}>
                      {typeof m.fruits === 'string' ? JSON.parse(m.fruits).join(', ') : (m.fruits?.join(', ') || '-')}
                    </div>
                  </div>
                ))}
              </div>
            ) : <div style={{ fontSize: '13px', color: 'var(--ink-muted)' }}>No fruit menu configured.</div>}
          </div>

          {/* Snacks Menu */}
          <div className="atelier" style={{ padding: '24px' }}>
            <h3 className="font-display" style={{ fontSize: '18px', marginBottom: '16px' }}>Snacks Menu</h3>
            {menus.snacks?.length > 0 ? (
              <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(250px, 1fr))', gap: '16px' }}>
                {menus.snacks.map((m, i) => (
                  <div key={i} style={{ padding: '12px', border: '1px solid var(--hairline)', borderRadius: '8px', background: 'var(--paper-2)' }}>
                    <div className="eyebrow" style={{ marginBottom: '8px' }}>Day {m.day_of_week} · Session {m.session}</div>
                    <div style={{ fontSize: '13px', color: 'var(--ink)', lineHeight: 1.5 }}>
                      {typeof m.items === 'string' ? JSON.parse(m.items).join(', ') : (m.items?.join(', ') || '-')}
                    </div>
                  </div>
                ))}
              </div>
            ) : <div style={{ fontSize: '13px', color: 'var(--ink-muted)' }}>No snacks menu configured.</div>}
          </div>
        </div>
      )}
    </div>
  );
}
