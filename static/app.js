const express = require('express');
const session = require('express-session');
const { Pool } = require('pg');
const app = express();

app.use(session({
    secret: 'ecret',
    resave: false,
    saveUninitialized: true,
}));

const pool = new Pool({
    user: 'your_user',
    host: 'your_host',
    database: 'your_database',
    password: 'your_password',
    port: 5432,
});

app.get('/posts', async (req, res) => {
    const communityId = req.query.community_id;

    if (!communityId) {
        return res.status(400).json({ error: 'Missing community_id' });
    }

    try {
        const client = await pool.connect();

        const result = await client.query('SELECT * FROM get_posts($1)', [communityId]);

        const posts = result.rows.map(async (post) => {
            const result2 = await client.query('SELECT * FROM get_replies($1)', [post.id_posta]);

            return {
                ...post,
                replies: result2.rows,
            };
        });

        const postsWithReplies = await Promise.all(posts);

        res.json(postsWithReplies);
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Internal server error' });
    }
});

app.listen(3000, () => {
    console.log('Server listening on port 3000');
});