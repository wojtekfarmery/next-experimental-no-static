"use client";

import styles from "./page.module.css";

const exampleEnv = process.env.NEXT_PUBLIC_EXAMPLE_ENV || "not set";

export const ClientEnvExample = () => {
  return (
    <div className={styles.envBox}>
      <h3>Runtime Environment Variable on the client side</h3>
      <code>NEXT_PUBLIC_EXAMPLE_ENV = {exampleEnv}</code>
    </div>
  );
};
