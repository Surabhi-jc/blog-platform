import React, {useState, useEffect} from "react";
import {useNavigate, useParams} from "react-router-dom";
import "./CreateBlogPage.css";

const CreateBlogPage = () => {
    const navigate = useNavigate();
    const { id } = useParams(); // blogId from route (null if creating)

    const [title, setTitle] = useState("");
    const [content, setContent] = useState("");
    const [tags, setTags] = useState("");
    const [error, setError] = useState("");
    const [availableTags, setAvailableTags] = useState([]);
    const [selectedTags, setSelectedTags] = useState([]);
    const [dropdownOpen, setDropdownOpen] = useState(false);
    const [loading, setLoading] = useState(false);



    const token= sessionStorage.getItem('token');


//load tags
    useEffect(() => {
        fetch("/api/tags")
            .then((res) => res.json())
            .then((data) => setAvailableTags(data.tags || []))
            .catch((err) => console.error("Failed to load tags", err));
    }, []);

    //if editing, fetch blog details
    useEffect(() => {
        if (id) {
            setLoading(true);
            fetch(`/api/blog/${id}`, {
                headers: {
                    Authorization: `Bearer ${token}`,
                },
            })
                .then((res) => res.json())
                .then((data) => {
                    setTitle(data.title || "");
                    setContent(data.content || "");
                    if (data.tags) {
                        const matchedIds = data.tags
                            .map((tagName) => {
                                const match = availableTags.find((t) => t.name === tagName);
                                return match ? match.id : null;
                            })
                            .filter((id) => id !== null);
                        setSelectedTags(matchedIds);
                    }
                })
                .catch(() => setError("Failed to load blog data"))
                .finally(() => setLoading(false));
        }
    }, [id, token, availableTags]);
    const toggleDropdown = () => {
        setDropdownOpen(!dropdownOpen);
    };

    const handleTagClick = (tagId) => {
        if (!selectedTags.includes(tagId)) {
            setSelectedTags([...selectedTags, tagId]);
        }
    };
    const removeTag = (tagId) => {
        setSelectedTags(selectedTags.filter((t) => t !== tagId));
    };



    const handleSubmit = async (e) => {
        e.preventDefault();

        const blogData = {
            blog: {
                title,
                content,
                tag_ids: selectedTags
            }
        };

        try{
            const response= await fetch(id ? `/blog/${id}` : '/api/blog',{
                method: id ? 'PUT' : 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify(blogData),
            });

            if(response.ok) {
                navigate('/profile');
            } else {
                const errorData = await response.json();
                setError(errorData.message||'Failed to create blog');
            }

        } catch(err){
            setError('Error occurred while creating a blog');
        }
    }

    if (loading) return <p>Loading blog data...</p>;

    return (
        <div className="create-blog-container card mt-lg-5 p-5">
            <h1 className={"text-center"}>{id ? "Update Blog" : "Create New Blog"}</h1>
            {error && <p className="error-text">{error}</p>}

            <form onSubmit={handleSubmit} className="d-flex flex-column gap-3">
                <div className="mb-3">
                    <label htmlFor="title" className="form-label">Title</label>
                    <input
                        id="title"
                        type="text"
                        className="form-control"
                        value={title}
                        onChange={(e)=> setTitle(e.target.value)}
                        required
                    />
                </div>

                <div className="mb-3">
                    <label htmlFor="content" className="form-label">Content</label>
                    <textarea
                        id="content"
                        className="form-control"
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                        required
                        rows={6}
                    />
                </div>

                <label>Select Tags:</label>
                <div className="tag-selector">
                    <div className="selected-tags-box">

                        {selectedTags.map((tagId) => {
                            const tag = availableTags.find(t => t.id === tagId);
                            return (
                                <div key={tagId} className="tag-item">
                                    {tag ? tag.name : tagId}
                                    <span className="remove-tag" onClick={() => removeTag(tagId)}>×</span>
                                </div>
                            );
                        })}
                    </div>
                    <button
                        type="button"
                        className="dropdown-toggle"
                        onClick={toggleDropdown}
                    >
                        {dropdownOpen ? "▲" : "▼"}
                    </button>
                </div>

                {dropdownOpen && (
                    <div className="dropdown-list">
                        {availableTags.map((tag) => (
                            <div
                                key={tag.id}
                                className={`dropdown-item ${
                                    selectedTags.includes(tag.id) ? "selected" : ""
                                }`}
                                onClick={() => handleTagClick(tag.id)}
                            >
                                {tag.name}
                            </div>
                        ))}
                    </div>
                )}

                <button type="submit" className="btn btn-success mt-2">
                    {id ? "Update Blog" : "Publish Blog"}
                </button>
            </form>

        </div>
    );
};

export default CreateBlogPage;