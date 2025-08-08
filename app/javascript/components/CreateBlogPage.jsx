import React, {useState} from "react";
import {useNavigate} from "react-router-dom";

const CreateBlogPage = () => {
    const navigate = useNavigate();

    const [title, setTitle] = useState("");
    const [content, setContent] = useState("");
    const [tags, setTags] = useState("");
    const [error, setError] = useState("");

    const token= sessionStorage.getItem('token');
    const handleSubmit = async (e) => {
        e.preventDefault();

        const blogData = {
            title,
            content,
            tags: tags.split(',').map(tag => tag.trim()),
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
                navigate('/');
            } else {
                const errorData = await response.json();
                setError(errorData.message||'Failed to create blog');
            }

        } catch(err){
            setError('Error occurred while creating a blog');
        }
    }

    return (
        <div>
            <h1>Create new blog</h1>
            {error && <p className="text-red-600 mb-2">{error}</p>}

            <form onSubmit={handleSubmit}>
                <div>
                    <label>Title</label>
                    <input
                        type="text"
                        value={title}
                        onChange={(e)=> setTitle(e.target.value)}
                    />
                </div>

                <div>
                    <label>Content</label>
                    <textarea
                        value={content}
                        onChange={(e) => setContent(e.target.value)}
                    />
                </div>
                <div>
                    <label>Tags (comma-separated)</label>
                    <input
                        type="text"
                        value={tags}
                        onChange={(e) => setTags(e.target.value)}

                    />
                </div>

                <button type="submit">Publish Blog</button>


            </form>
        </div>
    );
};

export default CreateBlogPage;