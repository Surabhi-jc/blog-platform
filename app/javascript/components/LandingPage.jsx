import React, { useEffect, useState, useRef, useCallback } from "react";
import "./LandingPage.css";
import { useNavigate } from "react-router-dom";
import BlogFeed from "./Blogfeed";

const LandingPage = () => {
    const [blogs, setBlogs] = useState([]);
    const [cursor, setCursor] = useState(null);
    const [hasMore, setHasMore] = useState(true);
    const [loading, setLoading] = useState(false);

    // refs to avoid race conditions / stale closures
    const loadingRef = useRef(false);
    const hasMoreRef = useRef(true);
    const loadMoreRef = useRef(null);

    const navigate = useNavigate();

    useEffect(() => { loadingRef.current = loading; }, [loading]);
    useEffect(() => { hasMoreRef.current = hasMore; }, [hasMore]);

    // Fetch function (uses cursor). Only depends on cursor.
    const fetchBlogs = useCallback(async () => {
        if (loadingRef.current) return;
        if (!hasMoreRef.current) return;

        setLoading(true);
        loadingRef.current = true;

        try {
            let url = `/api/blog/show?limit=10`;
            if (cursor) url += `&after=${encodeURIComponent(cursor)}`;

            console.log("Fetching:", url);
            const res = await fetch(url);
            if (!res.ok) {
                console.error("Backend error fetching blogs", await res.text());
                return;
            }

            const data = await res.json();
            console.log("Fetched batch:", data.blogs?.length, "next_cursor:", data.next_cursor, "has_more:", data.has_more);

            if (Array.isArray(data.blogs)) {
                setBlogs(prev => {
                    // dedupe by id
                    const existing = new Set(prev.map(b => b.id));
                    const newUnique = data.blogs.filter(b => !existing.has(b.id));
                    if (newUnique.length !== data.blogs.length) {
                        console.warn("Filtered duplicate ids:", data.blogs.map(b => b.id).filter(id => existing.has(id)));
                    }
                    return [...prev, ...newUnique];
                });
            }

            setCursor(data.next_cursor || null);
            setHasMore(!!data.has_more);
        } catch (err) {
            console.error("Error fetching blogs:", err);
        } finally {
            setLoading(false);
            loadingRef.current = false;
        }
    }, [cursor]);

    // initial load
    useEffect(() => {
        fetchBlogs();
        // eslint-disable-next-line react-hooks/exhaustive-deps
    }, []);

    // IntersectionObserver to load more when sentinel is near viewport
    useEffect(() => {
        const el = loadMoreRef.current;
        if (!el) return;

        const observer = new IntersectionObserver(
            entries => {
                const ent = entries[0];
                if (ent.isIntersecting) {
                    console.log("Sentinel intersecting — requesting more");
                    fetchBlogs();
                }
            },
            {
                root: null,
                rootMargin: "300px", // triggers earlier for smoother loading
                threshold: 0
            }
        );

        observer.observe(el);
        return () => {
            observer.unobserve(el);
        };
    }, [fetchBlogs]);

    return (
        <div>
            <h2 className="section-title text-center fw-normal mt-4">Latest Blogs</h2>

            <BlogFeed blogs={blogs} setBlogs={setBlogs} showEdit={false} />

            {/* Loader / sentinel */}
            <div
                ref={loadMoreRef}
                style={{ height: "60px", display: "flex", alignItems: "center", justifyContent: "center" }}
            >
                {loading && <p className="text-center">Loading more blogs...</p>}
                {!hasMore && <p className="text-center">No more blogs to show</p>}
            </div>
        </div>
    );
};

export default LandingPage;
