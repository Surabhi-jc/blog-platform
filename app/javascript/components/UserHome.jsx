import React, { useEffect, useState, useRef, useCallback } from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";
import BlogFeed from "./Blogfeed";

const PreferredBlogs = ({ user }) => {
    const [blogs, setBlogs] = useState([]);
    const [error, setError] = useState("");
    const [activeTab, setActiveTab] = useState("recommended");

    const [cursor, setCursor] = useState(null);
    const [hasMore, setHasMore] = useState(true);
    const [loading, setLoading] = useState(false);

    const loadMoreRef = useRef(null);
    const loadingRef = useRef(false);
    const hasMoreRef = useRef(true);

    const token = localStorage.getItem("token");
    const navigate = useNavigate();

    useEffect(() => { loadingRef.current = loading; }, [loading]);
    useEffect(() => { hasMoreRef.current = hasMore; }, [hasMore]);

    const fetchBlogs = useCallback(async () => {
        if (!token) return;
        if (loadingRef.current) return;
        if (!hasMoreRef.current) return;

        loadingRef.current = true;
        setLoading(true);

        try {
            let url =
                activeTab === "recommended"
                    ? "/api/blog/prefered_blogs?limit=10"
                    : "/user/following_blogs?limit=10";

            if (cursor) url += `&after=${encodeURIComponent(cursor)}`;

            const res = await fetch(url, {
                headers: { Authorization: `Bearer ${token}` },
            });

            if (!res.ok) {
                const txt = await res.text();
                throw new Error(txt || "Failed to load blogs");
            }

            const data = await res.json();

            // append with dedupe
            setBlogs(prev => {
                const existing = new Set(prev.map(b => b.id));
                const incoming = Array.isArray(data.blogs) ? data.blogs : [];
                const unique = incoming.filter(b => !existing.has(b.id));
                if (unique.length !== incoming.length) {
                    console.warn("Filtered duplicates:", incoming.map(b => b.id).filter(id => existing.has(id)));
                }
                return [...prev, ...unique];
            });

            setCursor(data.next_cursor || null);
            setHasMore(Boolean(data.has_more));
        } catch (err) {
            console.error("fetchBlogs error:", err);
            setError(err.message || "Failed to load blogs");
        } finally {
            setLoading(false);
            loadingRef.current = false;
        }
    }, [token, activeTab, cursor]);

    // reset when switching tabs
    useEffect(() => {
        setBlogs([]);
        setCursor(null);
        setHasMore(true);
        setError("");
        fetchBlogs();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, [activeTab, token]);

    // Intersection observer (triggers earlier for smoothness)
    useEffect(() => {
        const el = loadMoreRef.current;
        if (!el) return;

        const obs = new IntersectionObserver(
            (entries) => {
                if (entries[0].isIntersecting) {
                    fetchBlogs();
                }
            },
            {
                root: null,
                rootMargin: "400px", // trigger earlier
                threshold: 0
            }
        );

        obs.observe(el);
        return () => obs.disconnect();
    }, [fetchBlogs]);

    const handleCreateBlog = () => navigate("/Blog");

    return (
        <div>
            <div className="d-flex align-items-center justify-content-between mb-3 mt-2 mx-5">
                <div className="flex-grow-1 text-start">
                    {user && <h5 className="title-style">Hello, {user.name}!</h5>}
                </div>
                <div className="flex-grow-1 text-center">
                    <h5 className="title-style">Blogs for you</h5>
                </div>
                <div className="flex-grow-1 text-end ">
                    <button type="button" onClick={handleCreateBlog} className="btn btn-success">
                        Create New Blog
                    </button>
                </div>
            </div>

            <ul className="nav nav-tabs mb-3 justify-content-center">
                <li className="nav-item">
                    <button className={`nav-link ${activeTab === "recommended" ? "active" : ""}`} onClick={() => setActiveTab("recommended")}>Recommended</button>
                </li>
                <li className="nav-item">
                    <button className={`nav-link ${activeTab === "following" ? "active" : ""}`} onClick={() => setActiveTab("following")}>Following</button>
                </li>
            </ul>

            {error && <p className="text-danger text-center">{error}</p>}
            <BlogFeed blogs={blogs} setBlogs={setBlogs} showEdit={false} />

            <div ref={loadMoreRef} style={{ height: 60, display: "flex", alignItems: "center", justifyContent: "center" }}>
                {loading && <p>Loading more blogs...</p>}
                {!hasMore && <p>No more blogs to show</p>}
            </div>
        </div>
    );
};

export default PreferredBlogs;
