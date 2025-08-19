import React, {useState, useEffect} from "react";
import {useNavigate} from "react-router-dom";
import "./CreateBlogPage.css";

const CreateBlogPage = () => {
    const navigate = useNavigate();

    const [title, setTitle] = useState("");
    const [content, setContent] = useState("");
    const [tags, setTags] = useState("");
    const [error, setError] = useState("");
    const [availableTags, setAvailableTags] = useState([]);
    const [selectedTags, setSelectedTags] = useState([]);
    const [dropdownOpen, setDropdownOpen] = useState(false);


    const token= sessionStorage.getItem('token');



    useEffect(() => {
        fetch("/api/tags")
            .then((res) => res.json())
            .then((data) => setAvailableTags(data.tags || []))
            .catch((err) => console.error("Failed to load tags", err));
    }, []);
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
            const response= await fetch('/api/blog',{
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                    'Authorization': `Bearer ${token}`,
                },
                body: JSON.stringify(blogData),
            });

            if(response.ok) {
                navigate('/blogs/prefered_blogs');
            } else {
                const errorData = await response.json();
                setError(errorData.message||'Failed to create blog');
            }

        } catch(err){
            setError('Error occurred while creating a blog');
        }
    }

    return (
        <div className="create-blog-container">
            <h1>Create new blog</h1>
            {error && <p className="error-text">{error}</p>}

            <form onSubmit={handleSubmit}>
                <div>
                    <label>Title</label>
                    <input
                        type="text"
                        value={title}
                        onChange={(e)=> setTitle(e.target.value)}
                        required
                    />
                </div>

                <div>
                    <label>Content</label>
                    <textarea
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                        required
                    />
                </div>

                <label>Select Tags:</label>
                <div className="tag-selector">
                    <div className="selected-tags-box">
                        {/*} {selectedTags.map((tagId) => (
                            <div key={tag} className="tag-item">
                                {tag}
                                <span className="remove-tag" onClick={() => removeTag(tag)}>
                  ×
                </span>
                            </div>
                        ))} */}
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

                <button type="submit" className="publish-btn">Publish Blog</button>


            </form>
        </div>
    );
};

export default CreateBlogPage;