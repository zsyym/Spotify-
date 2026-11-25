require("dotenv").config();

const { Resend } = require("resend");

const resend = new Resend(process.env.RESEND_API_KEY);

async function main() {
    const { data, error } = await resend.emails.send({
        from: process.env.EMAIL_FROM,
        to: [process.env.TEST_EMAIL],
        subject: "Spotify Clone - Email Verification",
        html: `
            <h2>Email Verification</h2>
            <p>Your test verification code is:</p>
            <h1 style="color: #1ED760;">123456</h1>
            <p>This is a development test email.</p>
        `
    });

    if (error) {
        console.error("发送失败:", error.message);
        process.exitCode = 1;
        return;
    }

    console.log("邮件请求已被接受:", data);
}

main().catch((error) => {
    console.error("发生异常:", error.message);
    process.exitCode = 1;
});